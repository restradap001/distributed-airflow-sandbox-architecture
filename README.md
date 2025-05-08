# distributed-airflow-sandbox-architecture

A TypeScript CDK-based AWS architecture for mounting a distributed Apache Airflow sandbox environment.

## Setting Up the Environment

This project is designed to be used within a Dev Container, which includes all necessary tools and dependencies pre-installed. Follow the steps below to set up the environment and deploy the CDK app.

### Prerequisites

Ensure you have the following installed on your local machine:

- Docker (to run the Dev Container)
- Visual Studio Code with the Remote - Containers extension

### Steps to Set Up and Deploy

1. **Open the Dev Container**
   - Clone this repository to your local machine.
   - Open the repository in Visual Studio Code.
   - When prompted, reopen the project in the Dev Container. Alternatively, you can use the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P` on macOS) and select `Remote-Containers: Reopen in Container`.

2. **Install Dependencies**
   - Navigate to the `cdk-project` directory:
     ```bash
     cd cdk-project
     ```
   - Run the following command to install the required Node.js dependencies:
     ```bash
     npm install
     ```

3. **Bootstrap the CDK Environment**
   - Before deploying the CDK app, bootstrap the environment by running:
     ```bash
     npx cdk bootstrap
     ```

4. **Deploy the CDK App**
   - To deploy the CDK app, run:
     ```bash
     npx cdk deploy
     ```
   - Follow the prompts to confirm the deployment.

5. **Verify the Deployment**
   - After the deployment is complete, you can verify the resources created in your AWS account using the AWS Management Console or the AWS CLI.

### Additional Commands

- **Synthesize the CloudFormation Template**
  - To generate the CloudFormation template without deploying, run:
    ```bash
    npx cdk synth
    ```

- **Run Tests**
  - To run the tests for this project, use:
    ```bash
    npm test
    ```

### Cleaning Up

To remove the deployed resources, run:
```bash
npx cdk destroy
```

## Notes

- This project uses the AWS CDK (Cloud Development Kit) with TypeScript.
- Ensure your AWS credentials are configured correctly in the Dev Container for deployment.
- The Dev Container includes pre-installed tools such as Node.js, npm, TypeScript, AWS CLI, and Git LFS to streamline development.
