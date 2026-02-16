"use client";

import { useTheme } from "next-themes";
import { useEffect, useState } from "react";

interface ThemedScreenshotProps {
  lightSrc: string;
  darkSrc: string;
  alt: string;
  className?: string;
}

export function ThemedScreenshot({
  lightSrc,
  darkSrc,
  alt,
  className,
}: ThemedScreenshotProps) {
  const { resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) {
    return (
      <img src={lightSrc} alt={alt} className={className} loading="lazy" />
    );
  }

  const src = resolvedTheme === "dark" ? darkSrc : lightSrc;

  return <img src={src} alt={alt} className={className} loading="lazy" />;
}
