"use client";

import { Hero } from "@/components/sections/hero";
import { Pain } from "@/components/sections/pain";
import { HowItWorks } from "@/components/sections/how-it-works";
import { FeatureShowcase } from "@/components/sections/feature-showcase";
import { ProvidersStrip } from "@/components/sections/providers-strip";
import { Comparison } from "@/components/sections/comparison";
import { Testimonials } from "@/components/sections/testimonials";
import { DownloadCTA } from "@/components/sections/download-cta";
import { Footer } from "@/components/sections/footer";
import { ScrollProgress } from "@/components/ui/scroll-progress";
import { Navbar } from "@/components/navbar";

export default function Home() {
  return (
    <>
      {/* Scroll progress bar */}
      <ScrollProgress className="fixed top-0 z-50 h-0.5 bg-gradient-to-r from-[var(--gradient-start)] via-[var(--gradient-mid)] to-[var(--gradient-end)]" />

      <Navbar />

      <main>
        <Hero />
        <Pain />
        <HowItWorks />
        <FeatureShowcase />
        <ProvidersStrip />
        <Comparison />
        <Testimonials />
        <DownloadCTA />
        <Footer />
      </main>
    </>
  );
}
