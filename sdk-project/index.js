import { EC2Client, RunInstancesCommand } from '@aws-sdk/client-ec2';
import { readFileSync } from 'fs';

const IAM_INSTANCE_PROFILE_ARN = process.env.IAM_INSTANCE_PROFILE_ARN;
const IMAGE_ID = process.env.IMAGE_ID;
const INSTANCE_TYPE = process.env.INSTANCE_TYPE;
const KEY_NAME = process.env.KEY_NAME;
const SECURITY_GROUP = process.env.SECURITY_GROUP;
const SUBNET_ID = process.env.SUBNET_ID;
const ENV = process.env.ENV;

export async function main() {
    try {
        const ec2Client = new EC2Client({});

        const userData = readFileSync('sdk-project/startup.sh', 'utf8');
        const instanceNames = [
            `sdk-ec2-instance-${ENV}`
        ];

        for (const name of instanceNames) {
            const params = {
                MaxCount: 1,
                MinCount: 1,
                BlockDeviceMappings: [
                    {
                        DeviceName: '/dev/sda1',
                        Ebs: {
                            DeleteOnTermination: true,
                            Encrypted: false,
                            Throughput: 125,
                            VolumeSize: 64,
                            VolumeType: 'gp3'
                        }
                    }
                ],
                DisableApiTermination: false,
                EbsOptimized: false,
                IamInstanceProfile: {
                    Arn: IAM_INSTANCE_PROFILE_ARN
                },
                ImageId: IMAGE_ID,
                InstanceType: INSTANCE_TYPE,
                KeyName: KEY_NAME,
                Monitoring: {
                    Enabled: false
                },
                NetworkInterfaces: [
                    {
                        AssociatePublicIpAddress: true,
                        DeleteOnTermination: true,
                        DeviceIndex: 0,
                        Groups: [
                            SECURITY_GROUP
                        ],
                        SubnetId: SUBNET_ID
                    }
                ],
                TagSpecifications: [
                    {
                        ResourceType: 'instance',
                        Tags: [
                            {
                                Key: 'Name',
                                Value: name
                            }
                        ]
                    }
                ],
                UserData: Buffer.from(userData).toString('base64')
            };

            const command = new RunInstancesCommand(params);
            const response = await ec2Client.send(command);

            console.log(`EC2 Instance created with ID: ${response.Instances[0].InstanceId} and Name: ${name}`);
        }
    } catch (err) {
        console.error('Error creating EC2 instances:', err);
    }
};

main();
