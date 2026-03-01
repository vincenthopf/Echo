import type { Metadata } from "next";
import Script from "next/script";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { RootProvider } from "fumadocs-ui/provider/next";
import { SmoothCursor } from "@/components/ui/smooth-cursor";
import { SmoothScrollProvider } from "@/components/smooth-scroll-provider";
import { BackToTop } from "@/components/ui/back-to-top";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Echo — Voice to text for Mac",
  description:
    "The all-in-one voice tool for Mac. Local AI, cloud engines, smart formatting, and context-aware profiles. Free.",
  metadataBase: new URL("https://echo.vjh.io"),
  openGraph: {
    title: "Echo — Voice to text for Mac",
    description:
      "The all-in-one voice tool for Mac. Local AI, cloud engines, smart formatting, and context-aware profiles. Free.",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Echo — Voice to text for Mac",
    description:
      "The all-in-one voice tool for Mac. Local AI, cloud engines, smart formatting, and context-aware profiles. Free.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        {/* Polyfill esbuild's __name helper — prevents ReferenceError in OpenNext/Cloudflare bundles */}
        <script
          dangerouslySetInnerHTML={{
            __html: `if(typeof __name==="undefined"){var __name=function(t,v){Object.defineProperty(t,"name",{value:v,configurable:true});return t}}`,
          }}
        />
        <link
          rel="preload"
          href="/screenshots/Lightmode-dashboard.webp"
          as="image"
          type="image/webp"
          fetchPriority="high"
        />
        {process.env.NODE_ENV === "development" && (
          <Script
            src="//unpkg.com/react-grab/dist/index.global.js"
            crossOrigin="anonymous"
            strategy="beforeInteractive"
          />
        )}
        {process.env.NODE_ENV === "development" && (
          <Script
            src="//unpkg.com/@react-grab/claude-code/dist/client.global.js"
            strategy="lazyOnload"
          />
        )}
        {process.env.NEXT_PUBLIC_CLARITY_ID && (
          <Script
            id="microsoft-clarity"
            strategy="afterInteractive"
          >
            {`
              (function(c,l,a,r,i,t,y){
                  c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
                  t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
                  y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
              })(window, document, "clarity", "script", "${process.env.NEXT_PUBLIC_CLARITY_ID}");
            `}
          </Script>
        )}
      </head>
      <body
        className={`${geistSans.variable} ${geistMono.variable} font-sans antialiased`}
      >
        <RootProvider>
          <SmoothScrollProvider>
            {process.env.NODE_ENV !== "development" && <SmoothCursor />}
            {children}
            <BackToTop />
          </SmoothScrollProvider>
        </RootProvider>
      </body>
    </html>
  );
}
