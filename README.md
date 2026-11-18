# Secure CI/CD Pipeline to Amazon ECS

A GitHub Actions pipeline that builds a container image, scans it for secrets and vulnerabilities, and deploys it to Amazon ECS on Fargate. The AWS infrastructure is created with Terraform, and GitHub signs in to AWS with OIDC, so there are no stored access keys.

## What the pipeline does

On every push and pull request:

1. **Secret scan:** Gitleaks checks the code and its history for leaked secrets.
2. **Config scan:** Trivy checks the Dockerfile and Terraform for misconfigurations (report only).
3. **Build:** the container image is built and tagged with the git commit.
4. **Image scan:** Trivy checks the image, and the build fails if it finds fixable HIGH or CRITICAL vulnerabilities.

On pushes to `main` only, if the scans pass:

5. **Sign in to AWS** with a short-lived OIDC token.
6. **Push** the image to Amazon ECR.
7. **Deploy** it to ECS and wait for the service to become stable.

Pull requests never get AWS access.

## Security choices

| Area | What is done |
|------|--------------|
| AWS access | OIDC role instead of stored keys. Only the `main` branch of this repository can assume it. |
| Permissions | The deploy role can only push to one ECR repository and update one ECS service. |
| Secrets | Gitleaks scans every run. No credentials are in the repository. |
| Image | Runs as a non-root user, with a read-only root filesystem on ECS. |
| Registry | ECR scans on push, and image tags are immutable (each commit gets its own tag). |
| Vulnerabilities | The build fails on fixable HIGH or CRITICAL findings. |

## Architecture

```
Developer push
      |
      v
GitHub Actions
  scan secrets -> scan config -> build image -> scan image
      |
      |  OIDC (short-lived token, main branch only)
      v
     AWS
  Amazon ECR  ->  Amazon ECS (Fargate)  ->  CloudWatch Logs
```

## Project structure

```
.
├── app/                      # Small Node.js demo app and Dockerfile
├── terraform/                # ECR, ECS, IAM, OIDC, logging
└── .github/workflows/
    └── ci-cd.yml             # The pipeline
```

## Setup

**Requirements:** an AWS account, the AWS CLI configured, Terraform 1.10 or later, and a GitHub repository for this project.

1. **Create the infrastructure**
   ```
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` and set `github_repo` to `your-username/your-repo-name`. Then:
   ```
   terraform init
   terraform apply
   ```
   If your AWS account already has a GitHub OIDC provider, set `create_github_oidc_provider = false`.

2. **Add the role to GitHub.** Copy the `github_actions_role_arn` value from the Terraform output. In your repository go to Settings, Secrets and variables, Actions, and create a repository secret named `AWS_ROLE_ARN` with that value.

3. **Check the names.** The `env` block at the top of `.github/workflows/ci-cd.yml` uses the default names (`secure-cicd-...`) and the `eu-west-1` region. If you changed `app_name` or `aws_region` in Terraform, change them there too.

4. **Run the pipeline.** Push to `main`. Watch the run in the Actions tab.

5. **Open the app.** Find the task's public IP:
   ```
   TASK=$(aws ecs list-tasks --cluster secure-cicd-cluster --service-name secure-cicd-service --query 'taskArns[0]' --output text)
   ENI=$(aws ecs describe-tasks --cluster secure-cicd-cluster --tasks $TASK --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
   aws ec2 describe-network-interfaces --network-interface-ids $ENI --query 'NetworkInterfaces[0].Association.PublicIp' --output text
   ```
   Then open `http://<ip>:8080`. The page shows the git commit that was deployed.

## Cost and cleanup

Fargate and the logs cost a small amount while the service runs. When you finish testing:

```
cd terraform
terraform destroy
```

## Possible improvements

- Put an Application Load Balancer with HTTPS in front of the service
- Add unit tests as a pipeline stage
- Sign images and publish an SBOM
- Turn on Dependabot for the actions and base image
- Require pull requests and passing checks with branch protection
