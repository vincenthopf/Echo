import { ImageResponse } from "next/og";

export const runtime = "edge";
export const alt = "Download Echo for Mac";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function OGImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          background: "linear-gradient(135deg, #1C1917 0%, #292524 50%, #1C1917 100%)",
          fontFamily: "system-ui, sans-serif",
        }}
      >
        {/* Subtle warm glow behind icon */}
        <div
          style={{
            position: "absolute",
            width: 300,
            height: 300,
            borderRadius: "50%",
            background:
              "radial-gradient(circle, rgba(212,151,108,0.3) 0%, transparent 70%)",
            top: 120,
            display: "flex",
          }}
        />

        {/* App icon */}
        <img
          src="https://echo.vjh.io/app-icon.png"
          width={160}
          height={160}
          style={{ borderRadius: 32 }}
        />

        {/* Title */}
        <div
          style={{
            marginTop: 32,
            fontSize: 48,
            fontWeight: 700,
            color: "#FAFAF9",
            letterSpacing: "-0.02em",
            display: "flex",
          }}
        >
          Download Echo
        </div>

        {/* Subtitle */}
        <div
          style={{
            marginTop: 12,
            fontSize: 24,
            color: "#A8A29E",
            display: "flex",
          }}
        >
          Voice to text for Mac. Free.
        </div>
      </div>
    ),
    { ...size }
  );
}
