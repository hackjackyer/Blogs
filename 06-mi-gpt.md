# mi-gpt

## 下载编辑好.env和.migpt.js文件

```bash


docker run -d --env-file $(pwd)/.env -v $(pwd)/.migpt.js:/app/.migpt.js idootop/mi-gpt:latest
```