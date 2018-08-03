module.exports = function (context) {
    const azureArmContainerInstance = require('azure-arm-containerinstance');
    const azureArmContainerRegistry = require('azure-arm-containerregistry');
    const msRestAzure = require('ms-rest-azure');

    const RESOURCE_GROUP = 'azure-container-instance';
    const CONTAINER_GROUP = 'azure-container-instance';
    const REGION = 'centralus';
    const SUBSCRIPTION_ID = process.env.SUBSCRIPTION_ID;

    login()
        .then(deleteContainerGroup)
        .then(createContainerInstance)
        .then(returnSuccess)
        .catch(returnError);

    function login() {
        context.log('login');
        return new Promise((resolve, reject) => {
            const options = {
                msiEndpoint: process.env.MSI_ENDPOINT,
                msiSecret: process.env.MSI_SECRET
            };
            msRestAzure.loginWithAppServiceMSI(
                options,
                (err, credentials) => {
                    if (err) {
                        reject(err);
                    }
                    resolve(credentials);
                });
            });
    }

    function deleteContainerGroup(credentials) {
        context.log('delete');
        const client = new azureArmContainerInstance(credentials, SUBSCRIPTION_ID);
        return client.containerGroups.deleteMethod(RESOURCE_GROUP, CONTAINER_GROUP)
            .then((r) => {
                context.log('Delete complete');
                return credentials;
            });
    }

    function createContainerInstance(credentials) {
        context.log('create');
        const client = new azureArmContainerInstance(credentials, SUBSCRIPTION_ID);
        const container = new client.models.Container();

        container.name = 'hello';
        container.image = 'azurecontainerinstance.azurecr.io/hello:latest';
        container.resources = {
            requests: {
                cpu: 1,
                memoryInGB: 1
            }
        };

        return getContainerRegistryCredentials(credentials)
            .then((containerRegistryCredentials) => {
                return client.containerGroups.createOrUpdate(RESOURCE_GROUP, CONTAINER_GROUP,
                    {
                        containers: [container],
                        osType: 'Linux',
                        location: REGION,
                        restartPolicy: 'never',
                        imageRegistryCredentials: [containerRegistryCredentials]
                    }
                );
            });
    }

    function getContainerRegistryCredentials(credentials) {
        const client = new azureArmContainerRegistry.ContainerRegistryManagementClient(credentials, SUBSCRIPTION_ID);
        return client.registries.listCredentials(RESOURCE_GROUP, 'azurecontainerinstance')
            .then((containerRegistryCredentials) => {
                return {
                    username: containerRegistryCredentials.username,
                    password: containerRegistryCredentials.passwords[0].value,
                    server: 'azurecontainerinstance.azurecr.io'
                }
            });
    }

    function returnSuccess() {
        context.log('success');
        context.res = {
            status: 200,
            headers: {"Content-Type": "text/plain"},
            body: "Instance created!"
        };
        context.done();
    }

    function returnError(err) {
        context.log('error');
        context.res = {
            status: 500,
            headers: {"Content-Type": "text/plain"},
            body: err.message
        };
        context.done();
    }
};
