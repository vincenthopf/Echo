"use client";

import { TextAnimate } from "@/components/ui/text-animate";
import { MacbookScroll } from "@/components/ui/macbook-scroll";
import { useTheme } from "next-themes";
import { useEffect, useState } from "react";

export function Hero() {
  const { resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  const isDark = mounted && resolvedTheme === "dark";
  const screenshotSrc = isDark
    ? "/screenshots/Darkmode-dashboard.webp"
    : "/screenshots/Lightmode-dashboard.webp";

  return (
    <section className="relative w-full overflow-hidden bg-background">
      <MacbookScroll
        src={screenshotSrc}
        showGradient={true}
        title={
          <div className="mx-auto max-w-3xl px-6">
            <TextAnimate
              animation="fadeIn"
              by="word"
              as="h1"
              className="text-4xl font-bold tracking-tight text-black dark:text-white sm:text-5xl md:text-6xl lg:text-7xl"
              once
            >
              Think it. Say it. Done.
            </TextAnimate>

            <p className="mx-auto mt-6 max-w-xl text-lg text-neutral-600 dark:text-neutral-400 sm:text-xl">
              Voice-to-text for Mac. Local AI, cloud engines, and smart
              profiles — in one free app that respects your privacy.
            </p>

            <div className="mt-8">
              <a
                href="#features"
                className="group relative inline-flex w-auto cursor-pointer items-center overflow-hidden rounded-full border bg-background p-2 px-6 text-center font-semibold"
              >
                <div className="flex items-center gap-2">
                  <div className="h-2 w-2 rounded-full bg-primary transition-all duration-300 group-hover:scale-[100.8]"></div>
                  <span className="inline-block transition-all duration-300 group-hover:translate-x-12 group-hover:opacity-0">
                    See how it works
                  </span>
                </div>
                <div className="absolute top-0 z-10 flex h-full w-full translate-x-12 items-center justify-center gap-2 text-primary-foreground opacity-0 transition-all duration-300 group-hover:-translate-x-5 group-hover:opacity-100">
                  <span>See how it works</span>
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <path d="m6 9 6 6 6-6" />
                  </svg>
                </div>
              </a>
            </div>
          </div>
        }
      />
    </section>
  );
}
