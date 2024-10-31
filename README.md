# File Management Smart Contract

This smart contract provides a decentralized file management system where users can upload, update, delete, transfer, and manage access permissions for files stored on the blockchain. Each file is tokenized as an asset with unique ownership and metadata. Permissions can be granted or revoked for other users to access specific files.

## Features

- **File Upload**: Users can upload files with metadata such as file name, size, and creation timestamp. Each file is assigned a unique file ID.
- **File Update**: Owners can update file metadata, including the name and size, to reflect changes in the file.
- **File Deletion**: Owners can permanently delete a file, removing it from the system.
- **Ownership Transfer**: Owners can transfer ownership of a file to another user.
- **Permission Management**: Owners can grant or revoke access permissions for specific users on their files.
- **Statistics**: Read-only functions provide information on the total number of files and specific file metadata.

## Data Structures

### Constants

- **contract-owner**: The initial deployer of the contract, who has additional privileges.
- Various error codes are defined to indicate specific failure reasons, including ownership checks, invalid input, file existence, and unauthorized actions.

### Data Variables

- **total-files**: Tracks the cumulative count of files uploaded to the system.
- **files**: A map structure where each entry associates a file-id with file metadata and permissions.

### File Metadata (files Map)

Each file is stored with the following data:

- **owner**: Principal who uploaded and owns the file.
- **name**: ASCII string for the file name, up to 64 characters.
- **size**: File size in bytes.
- **created-at**: Block height at the time of upload.
- **permissions**: A map containing a recipient principal and a boolean for permission status.

### Permissions Structure

- **recipient**: Principal to whom the permission is granted or revoked.
- **permission**: Boolean indicating access (true for granted, false for revoked).

## Functions

### Public Functions

1. **(upload-file name size)**
    - Uploads a new file with specified name and size.
    - Increments the total-files counter and generates a unique file-id.
    - Initializes the permission for the file owner.
    - Returns the new file-id.

2. **(update-file file-id new-name new-size)**
    - Allows the owner to update the file’s name and size.
    - Validates input and checks that the caller is the file owner.
    - Returns true on success.

3. **(delete-file file-id)**
    - Deletes a file from the system.
    - Only the file owner can delete the file.
    - Returns true on successful deletion.

4. **(transfer-file-ownership file-id new-owner)**
    - Transfers ownership of a file to another user.
    - Verifies that the caller is the current owner.
    - Returns true on successful transfer.

5. **(grant-permission file-id permission recipient)**
    - Grants a specific permission to a recipient for accessing a file.
    - Only the file owner can grant permissions.
    - Returns true on success.

6. **(revoke-permission file-id permission recipient)**
    - Revokes a specific permission from a recipient for accessing a file.
    - Only the file owner can revoke permissions.
    - Returns true on success.

### Read-Only Functions

1. **(get-total-files)**
    - Returns the total number of files in the system.

2. **(get-file-info file-id)**
    - Retrieves metadata and permission information for a specific file by file-id.
    - Returns file information if it exists or an error if not found.

### Private Helper Functions

1. **(file-exists file-id)**
    - Checks if a file exists by file-id.

2. **(get-owner-file file-id owner)**
    - Checks if a file is owned by a specified principal.

3. **(get-file-size-by-owner file-id)**
    - Retrieves the file size by file-id.

## Error Codes

- **err-owner-only**: Only the contract owner can perform this action.
- **err-not-found**: File does not exist.
- **err-already-exists**: File with this ID already exists.
- **err-invalid-name**: Invalid name for the file.
- **err-invalid-size**: Invalid size for the file.
- **err-unauthorized**: Action not authorized for the caller.

## Usage Example

### Upload a File:

```clarity
(upload-file "example-file.txt" u1024)
```

### Grant Access:

```clarity
(grant-permission u1 true 'SP2…XYZ)
```

### Transfer Ownership:

```clarity
(transfer-file-ownership u1 'SP2…XYZ)
```

### Retrieve File Info:

```clarity
(get-file-info u1)
```

## Security Considerations

- **Ownership Checks**: Only the file owner can modify, delete, transfer ownership, or manage permissions.
- **Size Limits**: Each file’s size is validated to stay within defined boundaries.
- **Permission Updates**: Permission management prevents unauthorized access by ensuring only owners can grant or revoke permissions.

## Deployment and Testing

- **Testing**: Comprehensive testing should validate each function’s behavior, ensuring expected outcomes for permission changes, ownership transfers, and error handling.
- **Deployment**: Deploy this contract to the Stacks blockchain using Clarity-supported tools such as Clarinet.

11