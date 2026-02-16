"use client";

import { BlurFade } from "@/components/ui/blur-fade";
import { OrbitingCircles } from "@/components/ui/orbiting-circles";
import OpenAI from "@/components/icons/open-ai";
import Anthropic from "@/components/icons/anthropic";
import Gemini from "@/components/icons/gemini";
import MistralAI from "@/components/icons/mistral";
import Deepgram from "@/components/icons/deepgram";
import Nvidia from "@/components/icons/nvidia";

export function ProvidersStrip() {
  return (
    <section className="relative px-6 py-20 md:py-28">
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-transparent via-[var(--gradient-start)]/[0.03] to-transparent" />

      <div className="relative mx-auto max-w-5xl">
        <div className="grid items-center gap-12 md:grid-cols-[1fr_1.2fr] md:gap-16">
          {/* Text */}
          <BlurFade delay={0.1} inView direction="left">
            <div>
              <span className="text-sm font-semibold uppercase tracking-widest text-primary">
                Integrations
              </span>
              <h2 className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">
                The best of cloud.
                <br />
                The freedom of local.
              </h2>
              <p className="mt-4 text-muted-foreground leading-relaxed">
                OpenAI, Anthropic, Gemini, Mistral, Deepgram — every leading AI
                provider is one API key away. Or skip the cloud entirely and run
                Whisper or Parakeet right on your Mac. Both paths. One app.
                Always your data.
              </p>
            </div>
          </BlurFade>

          {/* Orbiting circles */}
          <BlurFade delay={0.3} inView direction="right">
            <div className="relative mx-auto flex h-[400px] w-full max-w-[400px] items-center justify-center">
              {/* Echo app icon at center */}
              <img
                src="/app-icon.png"
                alt="Echo"
                className="h-14 w-14 rounded-2xl shadow-lg"
              />

              {/* Inner orbit — cloud AI providers (reverse, slower) */}
              <OrbitingCircles
                radius={100}
                speed={0.5}
                iconSize={40}
                reverse
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-full border border-border bg-background shadow-sm">
                  <OpenAI className="h-5 w-5" />
                </div>
                <div className="flex h-10 w-10 items-center justify-center rounded-full border border-border bg-background shadow-sm">
                  <Anthropic className="h-5 w-5" />
                </div>
                <div className="flex h-10 w-10 items-center justify-center rounded-full border border-border bg-background shadow-sm">
                  <Gemini className="h-5 w-5" />
                </div>
              </OrbitingCircles>

              {/* Outer orbit — transcription & more providers */}
              <OrbitingCircles
                radius={170}
                speed={0.4}
                iconSize={36}
              >
                <div className="flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background shadow-sm">
                  <MistralAI className="h-4.5 w-4.5" />
                </div>
                <div className="flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background shadow-sm">
                  <Deepgram className="h-4.5 w-4.5" />
                </div>
                <div className="flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background shadow-sm">
                  <OpenAI className="h-4 w-4" />
                </div>
                <div className="flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background shadow-sm">
                  <Nvidia className="h-4.5 w-4.5" />
                </div>
              </OrbitingCircles>
            </div>
          </BlurFade>
        </div>
      </div>
    </section>
  );
}
