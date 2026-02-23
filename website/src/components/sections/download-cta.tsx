"use client";

import { useRef } from "react";
import { BlurFade } from "@/components/ui/blur-fade";
import { InteractiveHoverButton } from "@/components/ui/interactive-hover-button";
import { type ConfettiRef, Confetti } from "@/components/ui/confetti";
import { DottedGlowBackground } from "@/components/ui/dotted-glow-background";

export function DownloadCTA() {
  const confettiRef = useRef<ConfettiRef>(null);

  const handleDownloadClick = () => {
    confettiRef.current?.fire({
      particleCount: 100,
      spread: 70,
      origin: { y: 0.6 },
      colors: ["#F5A574", "#F09882", "#E87C9B", "#C4866C", "#D4976C"],
    });
    window.location.href = "/download";
  };

  return (
    <section id="pricing" className="relative overflow-hidden px-6 py-24 md:py-32">
      {/* Dotted glow background */}
      <DottedGlowBackground
        className="pointer-events-none"
        gap={16}
        radius={1.5}
        color="rgba(196, 134, 108, 0.5)"
        darkColor="rgba(212, 151, 108, 0.5)"
        glowColor="rgba(245, 165, 116, 0.85)"
        darkGlowColor="rgba(232, 124, 155, 0.85)"
        opacity={0.5}
        speedScale={0.8}
      />

      <div className="relative z-10 mx-auto max-w-2xl text-center">
        <BlurFade delay={0.1} inView>
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl md:text-5xl">
            Free. Forever. No catch.
          </h2>
        </BlurFade>

        <BlurFade delay={0.2} inView>
          <p className="mt-6 text-lg text-muted-foreground">
            Download Echo and start transcribing in under a minute. No account.
            No credit card. No data collection. Just your voice and your Mac.
          </p>
        </BlurFade>

        <BlurFade delay={0.3} inView>
          <div className="mt-8 flex flex-col items-center gap-3">
            <InteractiveHoverButton
              className="px-8 py-3 text-base"
              onClick={handleDownloadClick}
            >
              Download for Mac
            </InteractiveHoverButton>
            <p className="text-sm text-muted-foreground">
              macOS 13+ · Apple Silicon & Intel · Open source
            </p>
          </div>
        </BlurFade>
      </div>

      {/* Confetti canvas */}
      <Confetti
        ref={confettiRef}
        className="pointer-events-none absolute inset-0 z-50 h-full w-full"
        manualstart
      />
    </section>
  );
}
