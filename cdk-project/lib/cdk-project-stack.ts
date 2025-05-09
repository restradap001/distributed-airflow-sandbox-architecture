import { CfnOutput, CfnParameter, Duration, Stack, StackProps, Tags } from 'aws-cdk-lib';
import { DefaultInstanceTenancy, IpProtocol, KeyPair, KeyPairFormat, KeyPairType, MachineImage, NatProvider, Peer, Port, SecurityGroup, Vpc } from 'aws-cdk-lib/aws-ec2';
import { InstanceProfile, ManagedPolicy, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export class CdkProjectStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    const cfnEnvironmentParameter = new CfnParameter(this, 'ENV', {
      description: 'Environment',
      default: 'dev',
      type: 'String',
      allowedValues: [
        'dev',
        'test',
        'prod'
      ],
      minLength: 1,
      maxLength: 4,
      noEcho: false,
      constraintDescription: 'Must be one of the allowed values: dev, test, prod'
    });
    const ENV = cfnEnvironmentParameter.valueAsString;

    const ec2Vpc = new Vpc(this, 'EC2VPC', {
      createInternetGateway: true,
      defaultInstanceTenancy: DefaultInstanceTenancy.DEFAULT,
      enableDnsHostnames: true,
      enableDnsSupport: true,
      ipProtocol: IpProtocol.IPV4_ONLY,
      maxAzs: 1,
      natGatewayProvider: NatProvider.gateway(),
      reservedAzs: 0,
      vpcName: `cdk-ec2-vpc-${ENV}`
    });
    ec2Vpc.privateSubnets.forEach((subnet, index) => {
      Tags.of(subnet).add('Name', `cdk-ec2-private-subnet-${index + 1}-${ENV}`);
    });
    ec2Vpc.publicSubnets.forEach((subnet, index) => {
      Tags.of(subnet).add('Name', `cdk-ec2-public-subnet-${index + 1}-${ENV}`);
    });

    const ec2SecurityGroup = new SecurityGroup(this, 'EC2SecurityGroup', {
      allowAllIpv6Outbound: false,
      allowAllOutbound: true,
      description: undefined,
      disableInlineRules: false,
      securityGroupName: `cdk-ec2-security-group-${ENV}`,
      vpc: ec2Vpc
    });
    ec2SecurityGroup.addIngressRule(Peer.anyIpv4(), Port.SSH, 'Allow SSH access from the internet', false);
    ec2SecurityGroup.addIngressRule(Peer.anyIpv4(), Port.HTTP, 'Allow HTTP access from the internet', false);
    ec2SecurityGroup.addIngressRule(Peer.anyIpv4(), Port.HTTPS, 'Allow HTTPS access from the internet', false);

    const iamRole = new Role(this, 'IAMRole', {
      assumedBy: new ServicePrincipal('ec2.amazonaws.com'),
      description: 'IAM role for EC2 instance',
      maxSessionDuration: Duration.hours(1),
      path: '/',
      roleName: `cdk-ec2-role-${ENV}`
    });
    iamRole.addManagedPolicy(ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore'));

    const iamInstanceProfile = new InstanceProfile(this, 'InstanceProfile', {
      instanceProfileName: `cdk-ec2-instance-profile-${ENV}`,
      role: iamRole,
      path: '/'
    });

    const ec2KeyPair = new KeyPair(this, 'EC2KeyPair', {
      format: KeyPairFormat.PEM,
      keyPairName: `cdk-ec2-key-${ENV}`,
      type: KeyPairType.RSA
    });

    const ec2MachineImage = MachineImage.lookup({
      filters: {
        architecture: ['x86_64']
      },
      name: 'ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*',
      owners: ['099720109477'],
      userData: undefined,
      windows: false
    });

    new CfnOutput(this, 'IAMINSTANCEPROFILE__INSTANCEPROFILEARN', {
      description: 'Returns the ARN of this InstanceProfile.',
      key: 'instanceProfileArn',
      value: iamInstanceProfile.instanceProfileArn
    });

    new CfnOutput(this, 'EC2MACHINEIMAGE__IMAGEID', {
      description: 'The AMI ID of the image to use.',
      key: 'imageId',
      value: ec2MachineImage.getImage(this).imageId
    });

    new CfnOutput(this, 'EC2KEYPAIR__KEYPAIRNAME', {
      description: 'The unique name of the key pair.',
      key: 'keyName',
      value: ec2KeyPair.keyPairName
    });

    new CfnOutput(this, 'EC2SECURITYGROUP__SECURITYGROUPID', {
      description: 'The ID of the security group.',
      key: 'securityGroupId',
      value: ec2SecurityGroup.securityGroupId
    });

    new CfnOutput(this, 'EC2VPC__PUBLICSUBNETS__SUBNETID', {
      description: 'The subnetId for this particular subnet.',
      key: 'subnetId',
      value: ec2Vpc.publicSubnets[0].subnetId
    });

  }
}
