// Upload local files to Azure blob  ## for demo usage

// to use it, just run node Upload_files_to_Azure_blob.js <your local folder path> <your azure storage container name>

'use strict';
const { BlobServiceClient } = require('@azure/storage-blob');

async function main() {
    const AZURE_STORAGE_CONNECTION_STRING = "<your azure storage connection string>";
    // Create the BlobServiceClient object
    const blobServiceClient = BlobServiceClient.fromConnectionString(AZURE_STORAGE_CONNECTION_STRING);

    const args = process.argv.splice(2);
    const path = args[0];
    const fs = require('fs');
    const files = fs.readdirSync(path);
    const containerName = args[1];
    const containerClient = blobServiceClient.getContainerClient(containerName);

    let blobName = '';
    let blockBlobClient;
    let uploadBlobResponse;
    let stat;
    for (let i=0; i<files.length; i++)
    {
        blobName = files[i];
        // Get a block blob client
        blockBlobClient = containerClient.getBlockBlobClient(blobName);
        try {
            stat = fs.lstatSync(path + '/' + blobName);
            if (stat.isFile()) {
                uploadBlobResponse = await blockBlobClient.uploadFile(path + '/' + blobName);
                console.log(blobName, "uploaded. requestId: ", uploadBlobResponse.requestId);
                fs.unlinkSync(path + '/' + blobName);
                console.log(blobName, "deleted");
            }
            } catch (err) {
            console.error('An error occurred when uploading file:\n' + err.toString());
        }
    }

}

main().then(() => console.log('Done')).catch((ex) => console.log(ex.message));
