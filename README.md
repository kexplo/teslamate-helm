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
helm install teslamate teslamate-helm/teslamate -n teslamate -f your-values.yaml
```
