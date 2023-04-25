#  Download files from Azure blob  ## for demo usage

def retrieve_blob_data():
    from azure.storage.blob import ContainerClient
    from azure.storage.blob import BlobClient
    import datetime

    AZURE_STORAGE_CONNECTION_STRING = "<your azure storage connection string>"

    # Download the latest file in container

    AZURE_CONTAINER_NAME = "<container name>" 
    container = ContainerClient.from_connection_string(conn_str=AZURE_STORAGE_CONNECTION_STRING, container_name=AZURE_CONTAINER_NAME)
    blob_list = container.list_blobs()
    blob = list(blob_list)[-1]
    print(blob.name + '\n' + str(blob.last_modified))
    blobcli = BlobClient.from_connection_string(conn_str=AZURE_STORAGE_CONNECTION_STRING,
                                                    container_name=AZURE_CONTAINER_NAME,
                                                    blob_name=blob.name)
    with open("<your local file path>" + blob.name, "wb") as my_blob:
        blob_data = blobcli.download_blob()
        blob_data.readinto(my_blob)


    # Download files in 12 hours

    AZURE_CONTAINER_NAME = "<container name>"
    container = ContainerClient.from_connection_string(conn_str=AZURE_STORAGE_CONNECTION_STRING,
                                                       container_name=AZURE_CONTAINER_NAME)
    blob_list = container.list_blobs()
    from_date = (list(blob_list)[-1].last_modified - datetime.timedelta(hours=12))
    print(from_date)
    for blob in blob_list:
        blobcli = BlobClient.from_connection_string(conn_str=AZURE_STORAGE_CONNECTION_STRING,
                                                    container_name=AZURE_CONTAINER_NAME,
                                                    blob_name=blob.name)
        if str(blob.last_modified) > str(from_date):
            print(blob.name + '\n' + str(blob.last_modified))
            with open("<your local file path>" + blob.name, "wb") as my_blob:
                blob_data = blobcli.download_blob()
                blob_data.readinto(my_blob)


if __name__ == '__main__':
    retrieve_blob_data()

