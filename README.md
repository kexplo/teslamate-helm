# teslamate-helm

This is a Helm chart for [TeslaMate](https://github.com/teslamate-org/teslamate).

**Note:** This chart is not official TeslaMate chart.

## How to use

Add the chart repository:

```bash
helm repo add teslamate https://kexplo.github.io/teslamate-helm/
```

Install the chart:

```bash
helm install teslamate teslamate/teslamate -n teslamate -f your-values.yaml
```

## Database Backup to Google Drive

This chart supports automatic database backups to Google Drive using a CronJob.

### Prerequisites

1. **Create a Google Cloud OAuth2 Client**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Google Drive API
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - Choose "Desktop app" as the application type
   - Download the OAuth2 client credentials JSON file

2. **Generate OAuth2 Token**
   - Install required Python libraries:
     ```bash
     pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client
     ```
   - Create a Python script to generate the token (save as `generate_token.py`):
     ```python
     #!/usr/bin/env python3
     import json
     from google_auth_oauthlib.flow import InstalledAppFlow

     SCOPES = ['https://www.googleapis.com/auth/drive.file']

     def main():
         # Load client secrets
         flow = InstalledAppFlow.from_client_secrets_file(
             'client_secret.json',  # Your downloaded OAuth2 client credentials
             SCOPES
         )

         # Run local server for OAuth2 flow
         creds = flow.run_local_server(port=0)

         # Save token
         token_data = {
             'token': creds.token,
             'refresh_token': creds.refresh_token,
             'token_uri': creds.token_uri,
             'client_id': creds.client_id,
             'client_secret': creds.client_secret,
             'scopes': creds.scopes
         }

         with open('token.json', 'w') as token_file:
             json.dump(token_data, token_file, indent=2)

         print('Token saved to token.json')

     if __name__ == '__main__':
         main()
     ```
   - Run the script and complete the OAuth2 authorization flow in your browser:
     ```bash
     python3 generate_token.py
     ```
   - This will create a `token.json` file with your OAuth2 credentials

3. **Create Google Drive Folder**
   - Create a folder in your Google Drive where backups will be stored
   - Note the folder ID from the URL: `https://drive.google.com/drive/folders/FOLDER_ID`
   - No need to share the folder - it's already accessible through your OAuth2 credentials

4. **Create Kubernetes Secret**
   ```bash
   kubectl create secret generic teslamate-gdrive-credentials \
     --from-file=token.json=/path/to/your/token.json \
     -n teslamate
   ```

### Enable Backup

Update your `values.yaml`:

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  googleDrive:
    folderId: "YOUR_GOOGLE_DRIVE_FOLDER_ID"
    credentialsSecretName: "teslamate-gdrive-credentials"
```

### Configuration Options

| Key | Description | Default |
|-----|-------------|---------|
| `backup.enabled` | Enable database backup | `false` |
| `backup.schedule` | Cron schedule for backup | `"0 2 * * *"` |
| `backup.image.repository` | Backup job image | `postgres` |
| `backup.image.tag` | Backup job image tag | `17` |
| `backup.googleDrive.folderId` | Google Drive folder ID | `""` |
| `backup.googleDrive.credentialsSecretName` | Kubernetes secret name | `"teslamate-gdrive-credentials"` |

The backup files are named with timestamps: `teslamate_backup_YYYYMMDD_HHMMSS.sql.gz`

## Documentation

- [teslamate](https://kexplo.github.io/teslamate-helm/teslamate)
