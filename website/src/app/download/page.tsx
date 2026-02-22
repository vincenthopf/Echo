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
  },
  twitter: {
    card: "summary_large_image",
    title: "Download Echo — Voice to text for Mac",
    description:
      "Free voice-to-text for Mac. Local AI, cloud engines, and smart profiles that adapt to how you work.",
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
