# Deploy the Echo website

The site is a static export served as Worker static assets (no server code), on the `echo` Worker in Cloudflare account `3db5cf3eac3990b5604382b809bb46c6`. It is live at https://echo.vjh.workers.dev, and https://echo.vjh.io redirects there.

```bash
cd website
STATIC_EXPORT=1 NEXT_PUBLIC_CLARITY_ID=vkv3jkgfhd pnpm exec next build
cd ../deploy
pnpm install --ignore-workspace
CLOUDFLARE_ACCOUNT_ID=3db5cf3eac3990b5604382b809bb46c6 pnpm exec cf deploy
```
