import type { Metadata } from "next";
import { DownloadHero } from "@/components/sections/download-hero";
import { ReleaseHistory } from "@/components/sections/release-history";

export const metadata: Metadata = {
  title: "Download Echo — Voice to text for Mac",
  description:
    "Free voice-to-text for Mac. Local AI, cloud engines, and smart profiles that adapt to how you work. Download now.",
  openGraph: {
    title: "Download Echo — Voice to text for Mac",
    description:
      "Free voice-to-text for Mac. Local AI, cloud engines, and smart profiles that adapt to how you work.",
    type: "website",
    url: "https://echo.vjh.io/download",
    images: [
      {
        url: "https://echo.vjh.io/og-download.png",
        width: 1200,
        height: 630,
        alt: "Download Echo for Mac",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Download Echo — Voice to text for Mac",
    description:
      "Free voice-to-text for Mac. Local AI, cloud engines, and smart profiles that adapt to how you work.",
    images: ["https://echo.vjh.io/og-download.png"],
  },
  other: {
    "theme-color": "#C4866C",
  },
};

export default function DownloadPage() {
  return (
    <main>
      <DownloadHero />
      <ReleaseHistory />
    </main>
  );
}
