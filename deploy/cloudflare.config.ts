import { defineConfig } from "cf/config";

export default defineConfig({
	worker: {
		name: "echo",
		compatibilityDate: "2026-06-01",
		workersDev: true,
		previewUrls: false,
		assets: {
			htmlHandling: "auto-trailing-slash",
			notFoundHandling: "404-page",
		},
	},
});
