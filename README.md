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

1. **Create a Google Cloud Service Account**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Google Drive API
   - Create a Service Account and download the JSON credentials file

2. **Share Google Drive Folder with Service Account**
   - Create a folder in Google Drive where backups will be stored
   - Share the folder with the service account email (found in the credentials JSON)
   - Give "Editor" permissions to the service account
   - Note the folder ID from the URL: `https://drive.google.com/drive/folders/FOLDER_ID`

3. **Create Kubernetes Secret**
   ```bash
   kubectl create secret generic teslamate-gdrive-credentials \
     --from-file=credentials.json=/path/to/your/credentials.json \
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
