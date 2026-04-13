# Project Zeus: CI/CD Pipeline with Jenkins & Tomcat on AWS

## Project Overview

This project implements a complete CI/CD pipeline on AWS using Infrastructure as Code (IaC) with Terraform. 
It is a three-tier infrastructure consists of Jenkins, Tomcat and RDS-MySQL servers deployed in private subnets, 
with an Application Load Balancer providing external access. The entire Jenkins configuration is managed through 
Configuration as Code (JCasC), and jobs are defined using Job DSL.

## Architecture

- **Jenkins Server**: Master node running Jenkins WAR, fully configured via JCasC
- **Tomcat Server**: Application server hosting the deployed web application
- **RDS-MySQL server**: Database backend for the application
- **EFS**: Shared storage for deployment artifacts and versioned WAR files
- **Application Load Balancer**: External access point
- **AWS Secrets Manager**: Secure storage for credentials and tokens
- **Private Subnets**: Jenkins, Tomcat servers and MySQL servers reside in private subnets for security
- **Application deployment is handled via a **Pipeline** triggered by GitHub push events.

## Key Features

- **Automated Jenkins Setup**:
  - Latest Jenkins WAR installation
  - Automatic plugin installation from `plugins.txt`
  - JCasC (`jenkins.yaml`) for full configuration (security, tools, credentials, jobs)
  - Seed job using Job DSL to create the webapp pipeline dynamically
  - GitHub webhook integration for automatic triggering

- **Maven + Java 21** environment pre-configured on Jenkins

- **Tomcat 10** deployment target with:
  - Pre-configured users (`deployer`, `admin`)
  - Remote deployment support
  - EFS-mounted `webapps` directory for zero-downtime-ish deployments

- **Deployment Workflow**:
  - Build with Maven
  - Deploy WAR to EFS (shared with Tomcat)
  - Support for **Rollback** to previous versions
  - Automatic cleanup of old artifacts (keeps last 3 versions)

- **Secrets Management**:
  - AWS Secrets Manager for GitHub token, Jenkins admin password, etc.

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed
- Two Private GitHub repositories -  **manage-jenkins** and **maven-project-webapp**
- SSH key configured in GitHub for Jenkins to authenticate when accessing the **maven-project-webapp** repo
- Setup a github webhook for **maven-project-webapp** which will be triggered by push events
- Setup a fine-grained access token to be used for authentication when the webhook is triggered
- Setup a fine-grained access token for authentication to **manage-jenkins** when downloading plugins.txt or jenkins.yaml files


## Repository Structure

```
manage jenkins/
├── jenkins.yaml
├── plugins.txt
├── .github/
│   └── workflows/
│       └── update-jenkins-plugins.yml

maven-project-webapp/
├── pom.xml                                        # Maven build & dependency configuration
├── Jenkinsfile                                    # CI/CD pipeline definition 
├── README.md                                      # Project documentation
├── jenkins/
│   └── jobs/
│       └── webapp.groovy                          # Jenkins job configuration 
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/webapp/                # Backend Source Code 
│       │       ├── DBUtil.java                    # Database connection utility
│       │       ├── FlywayInitializer.java         # Database migration startup
│       │       ├── LoginServlet.java              # Login logic
│       │       └── RegisterServlet.java           # Registration logic
│       ├── resources/
│       │   └── db/migration/                      # Database Migration Scripts
│       │       ├── V1__create_table.sql           # Schema creation
│       │       └── V2__create_users.sql           # User table setup
│       └── webapp/                                # Frontend & Web Configuration
│           ├── login.jsp                          # Login Page
│           ├── register.jsp                       # Registration Page
│           ├── welcome.jsp                        # Success Landing Page
│           └── WEB-INF/              
│               └── web.xml                        # Servlet & Deployment Descriptor
```

## Infrastructure Components

### VPC Configuration
- Multi-AZ deployment for high availability
- NAT Instance for outbound internet access from private subnets

### Security Groups
- **Load Balancer SG**: Allows HTTP/HTTPS from internet
- **Jenkins SG**: Allows port 8080 from load balancer only
- **Tomcat SG**: Allows port 8080 from load balancer only
- **RDS SG**: Allows port 3306 from Tomcat SG only
- **EFS SG**: Allows NFS access from Jenkins and Tomcat security groups

### Storage (EFS)
- Shared file system mounted at `/mnt/efs_deploy` on Jenkins
- Mounted at `/opt/tomcat/webapps` on Tomcat
- Access Points for granular permissions control
- Stores current WAR file and versioned backups

### Database (RDS-MySQL)
- Uses a single-DB instance with multi-az disabled
- Enables IAM database authentication, allowing application to access the DB via the user app_user
- FlyWay is used to effect changes to the database through the admin user.  

## Jenkins Configuration

### User Data Script Highlights
- Installs Java 21, Maven 3.9.11, Git, and AWS CLI
- Downloads Jenkins WAR and plugin manager
- Installs plugins from `plugins.txt`
- Configures SSH for GitHub access
- Mounts EFS shared storage
- Sets up systemd service for Jenkins
- Creates update scripts for plugins and JCasC configuration

### JCasC (jenkins.yaml)
The `jenkins.yaml` file configures:
- **Admin User**: Created with password from AWS Secrets Manager
- **Tools**: Maven, Git, JDK installations
- **Credentials**: Tomcat deployment credentials
- **GitHub Integration**: Webhook configuration with PAT from Secrets Manager
- **Seed Job**: Creates pipeline jobs from Groovy scripts in GitHub repository

### Plugins
Key plugins installed:
- **workflow-aggregator**: Pipeline support
- **configuration-as-code**: JCasC functionality
- **job-dsl**: Job DSL plugin
- **aws-secrets-manager-credentials-provider**: AWS Secrets Manager integration
- **github**: GitHub integration
- **uno-choice**: Active Choices parameter for rollback functionality
- **aws-secrets-manager-secret-source**: Required to setup admin user password
- **jenkins-plugin-manager**: To automatically install plugins listed in the plugins.txt file

## Login to Servers via the Console

### Jenkins and Tomcat servers
- Use Session Manager SSM

### Database Server
- Install MySQL client on Tomcat using ```sudo dnf install mariadb105 -y```
- Type ``` mysql -h <DB-DNS> -P 3306 -u admin -p```
- Retrieve the admin password from secrets manager.

## Pipeline Workflow

### Trigger
- GitHub push to `maven-project-webapp` repository automatically triggers the pipeline

### Build Stage
- Checks out code from GitHub using SSH key
- Builds the Maven project
- Produces WAR artifact

### Deploy/Rollback Stage
**Normal Deployment:**
1. Archives current WAR to `/mnt/efs_deploy/old_versions/` with timestamp and build number
2. Copies new WAR to `/mnt/efs_deploy/my-webapp.war`
3. Tomcat automatically picks up the new version

**Rollback:**
1. User selects `IS_ROLLBACK` parameter to enable rollback mode
2. Approve the rollback script attached to the Active Choices plugin
3. Active Choices parameter populates dropdown with available WAR files
4. Selected WAR is restored as `my-webapp.war`
5. Tomcat deploys the previous version

### Cleanup
- Maintains only the last 3 WAR files in the `old_versions/` directory
- Automatically removes older versions

## Job DSL (webapp.groovy)

The DSL script creates the `webapp-pipeline` job with:
- GitHub push trigger
- Parameterized build supporting rollback
- Active Choices reactive parameter reading from EFS
- Jenkinsfile reference for pipeline definition

## Deployment Process

### Initial Infrastructure Deployment
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Post-Deployment Setup

1. **Access Jenkins** via load balancer DNS (may take 5-10 minutes for initialization)
2. **Initial admin password** retrieved from AWS Secrets Manager (`jenkins-admin-password`)
3. **Seed job** automatically creates the pipeline job on first GitHub push
4. **Approve script execution** when prompted for the pipeline job

### Pushing Code Changes to maven-project-webapp
```bash
git push origin main
```
This triggers:
1. GitHub webhook notification to Jenkins
2. Seed job execution (The first push requires your script approval)
3. Pipeline job creation/update 
4. Build and deployment

## Maintenance Scripts

### Update Jenkins Plugins
```bash
sudo /etc/jenkins/update-jenkins-plugins.sh
```

### Update JCasC Configuration
```bash
sudo /etc/jenkins/update-jenkins-config.sh
```

### Check Jenkins Logs
```bash
journalctl -u jenkins -f
```

### View Cloud-Init Logs
```bash
cat /var/log/cloud-init-output.log
```

### View Web Application Logs on Tomcat
```bash
cat /opt/tomcat/logs/catalina.out
```

## Making Configuration and plugin changes to Jenkins server
- Add the plugin or make plugins updates in plugins.txt file
- Add the configuration to jenkins.yaml file
- Make a commit to the **manage-jenkins** repository
- Github actions triggers the appropriate scripts

## Security Considerations

- **No direct SSH access** to Jenkins and Tomcat servers
- **Secrets stored in AWS Secrets Manager** (GitHub tokens, passwords)
- **Private subnets** for application servers
- **Security groups** restrict traffic to necessary ports only
- **SSH keys** for GitHub access managed securely
- **EFS encrypted** at rest and in transit
- **No hardcoded credentials** in scripts or configuration
- **Use of VPC endpoints** for SSM, KMS, S3 and Secrets Manager
- **Only tomcat server can access database server** and it does so through the app_user

### suggestions to harden security

- Remove/disable the manager apps entirely.
- Configure Tomcat for HTTPS (with a proper certificate) and set the ALB to forward HTTPS only. Disable HTTP connectors

## Troubleshooting

### Jenkins UI Not Accessible
- Check load balancer health status in AWS Console
- Verify security group rules allow traffic from load balancer
- Check Jenkins service: `systemctl status jenkins`
- Review Jenkins logs: `journalctl -u jenkins -n 100`

### EFS Mount Issues
- Verify mount: `mount | grep efs`
- Check permissions: `ls -la /mnt/efs_deploy/`
- Test write access: `sudo -u jenkins touch /mnt/efs_deploy/test.txt`

### GitHub Webhook Failures
- Verify GitHub token in Secrets Manager has correct permissions
- Check EC2 instance role has `secretsmanager:GetSecretValue` permission
- Test token retrieval: `aws secretsmanager get-secret-value --secret-id github-token`

### Pipeline Failures
- Check Jenkins console output for specific errors
- Verify EFS is writable by Jenkins user
- Confirm Maven and JDK tools are configured correctly

## Cleanup

To destroy all infrastructure:
```bash
cd terraform
terraform destroy
```

**Note**: This will delete all resources including EFS storage and secrets. Ensure you have backups if needed.

## Contributing

When modifying this infrastructure:
1. Test changes in a development environment first
2. Update documentation to reflect changes
3. Follow the "as-code" principles - no manual changes
4. Store all configuration in version control

## License

This project is proprietary and confidential.