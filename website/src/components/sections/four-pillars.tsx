"use client";

/**
 * Bento Grid — adapted from KokonutUI by @dorianbaffier (MIT)
 * https://kokonutui.com
 */

import { CheckCircle2, Mic, Plus } from "lucide-react";
import {
  motion,
  useMotionValue,
  useTransform,
  type Variants,
} from "motion/react";
import { useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";
import OpenAI from "@/components/icons/open-ai";
import OpenAIDark from "@/components/icons/open-ai-dark";
import Anthropic from "@/components/icons/anthropic";
import AnthropicDark from "@/components/icons/anthropic-dark";
import Gemini from "@/components/icons/gemini";
import MistralAI from "@/components/icons/mistral";
import Deepgram from "@/components/icons/deepgram";

/* ─── Types ─── */

interface BentoItem {
  id: string;
  title: string;
  description: string;
  feature?: "spotlight" | "typing" | "icons";
  spotlightItems?: string[];
  typingText?: string;
}

/* ─── Data ─── */

const bentoItems: BentoItem[] = [
  {
    id: "awareness",
    title: "Speak. Echo adapts.",
    description:
      "Profiles that switch by app, URL, or voice — automatically. Zero configuration.",
    feature: "spotlight",
    spotlightItems: [
      "App-specific formatting",
      "URL pattern matching",
      "Voice-activated triggers",
      "AI enhancement prompts",
      "Custom vocabulary",
    ],
  },
  {
    id: "pipeline",
    title: "Raw speech in. Polished text out.",
    description:
      "Choose your engine. Add your vocabulary. Enhance with AI. One pipeline, fully yours.",
    feature: "typing",
    typingText: `const echo = async (audio) => {
  // Pick engine: local or cloud
  const engine = selectEngine({
    local: 'whisper-large-v3',
    cloud: 'deepgram-nova-2'
  });

  // Transcribe with context
  const text = await engine.transcribe(audio, {
    language: 'auto',
    vocabulary: userDictionary
  });

  // AI enhancement
  return enhance(text, activeProfile);
};`,
  },
  {
    id: "providers",
    title: "Cloud or local. Your call.",
    description:
      "Leading AI providers built in. Full offline mode built in. Use both, use one, switch anytime.",
    feature: "icons",
  },
];

/* ─── Animations ─── */

const fadeInUp: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5, ease: "easeOut" },
  },
};

const staggerContainer: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.15, delayChildren: 0.3 },
  },
};

/* ─── Feature: Spotlight checklist ─── */

function SpotlightFeature({ items }: { items: string[] }) {
  return (
    <ul className="mt-2 space-y-1.5">
      {items.map((item, index) => (
        <motion.li
          key={item}
          className="flex items-center gap-2"
          initial={{ opacity: 0, x: -10 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.1 * index }}
        >
          <CheckCircle2 className="h-4 w-4 flex-shrink-0 text-primary" />
          <span className="text-sm text-muted-foreground">{item}</span>
        </motion.li>
      ))}
    </ul>
  );
}

/* ─── Feature: Typing code ─── */

function TypingCodeFeature({ text }: { text: string }) {
  const [displayedText, setDisplayedText] = useState("");
  const [currentIndex, setCurrentIndex] = useState(0);
  const terminalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (currentIndex < text.length) {
      const timeout = setTimeout(
        () => {
          setDisplayedText((prev) => prev + text[currentIndex]);
          setCurrentIndex((prev) => prev + 1);
          if (terminalRef.current) {
            terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
          }
        },
        Math.random() * 30 + 10
      );
      return () => clearTimeout(timeout);
    }
  }, [currentIndex, text]);

  useEffect(() => {
    setDisplayedText("");
    setCurrentIndex(0);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="relative mt-3">
      <div className="mb-2 flex items-center gap-2">
        <div className="text-xs text-muted-foreground">echo.ts</div>
      </div>
      <div
        ref={terminalRef}
        className="h-[150px] overflow-y-auto rounded-md bg-neutral-900 p-3 font-mono text-xs text-neutral-100 dark:bg-black"
      >
        <pre className="whitespace-pre-wrap">
          {displayedText}
          <span className="animate-pulse">|</span>
        </pre>
      </div>
    </div>
  );
}

/* ─── Feature: Provider icons grid ─── */

function IconsFeature() {
  const providers = [
    {
      label: "OpenAI",
      icon: (
        <>
          <OpenAI className="h-7 w-7 transition-transform dark:hidden" />
          <OpenAIDark className="hidden h-7 w-7 transition-transform dark:block" />
        </>
      ),
    },
    {
      label: "Anthropic",
      icon: (
        <>
          <Anthropic className="h-7 w-7 transition-transform dark:hidden" />
          <AnthropicDark className="hidden h-7 w-7 transition-transform dark:block" />
        </>
      ),
    },
    {
      label: "Gemini",
      icon: <Gemini className="h-7 w-7 transition-transform" />,
    },
    {
      label: "Mistral",
      icon: <MistralAI className="h-7 w-7 transition-transform" />,
    },
    {
      label: "Deepgram",
      icon: <Deepgram className="h-7 w-7 transition-transform" />,
    },
    {
      label: "More",
      icon: (
        <Plus className="h-6 w-6 text-muted-foreground transition-transform" />
      ),
    },
  ];

  return (
    <div className="mt-4 grid grid-cols-3 gap-4">
      {providers.map((p) => (
        <div
          key={p.label}
          className="group flex flex-col items-center gap-2 rounded-xl border border-border/50 bg-gradient-to-b from-secondary/80 to-secondary p-3 transition-all duration-300 hover:border-border"
        >
          <div className="relative flex h-8 w-8 items-center justify-center">
            {p.icon}
          </div>
          <span className="text-center text-xs font-medium text-muted-foreground group-hover:text-foreground">
            {p.label}
          </span>
        </div>
      ))}
    </div>
  );
}

/* ─── Voice Demo ─── */

function VoiceDemo() {
  const [submitted, setSubmitted] = useState(false);
  const [time, setTime] = useState(0);
  const [isClient, setIsClient] = useState(false);
  const [isDemo, setIsDemo] = useState(true);

  useEffect(() => {
    setIsClient(true);
  }, []);

  useEffect(() => {
    let intervalId: NodeJS.Timeout;
    if (submitted) {
      intervalId = setInterval(() => setTime((t) => t + 1), 1000);
    } else {
      setTime(0);
    }
    return () => clearInterval(intervalId);
  }, [submitted]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  };

  useEffect(() => {
    if (!isDemo) return;
    let timeoutId: NodeJS.Timeout;
    const runAnimation = () => {
      setSubmitted(true);
      timeoutId = setTimeout(() => {
        setSubmitted(false);
        timeoutId = setTimeout(runAnimation, 1000);
      }, 3000);
    };
    const initialTimeout = setTimeout(runAnimation, 100);
    return () => {
      clearTimeout(timeoutId);
      clearTimeout(initialTimeout);
    };
  }, [isDemo]);

  const handleClick = () => {
    if (isDemo) {
      setIsDemo(false);
      setSubmitted(false);
    } else {
      setSubmitted((prev) => !prev);
    }
  };

  return (
    <div className="w-full py-4">
      <div className="relative mx-auto flex w-full max-w-xl flex-col items-center gap-2">
        <button
          type="button"
          className={cn(
            "group flex h-16 w-16 items-center justify-center rounded-xl transition-colors",
            submitted
              ? "bg-none"
              : "bg-none hover:bg-secondary"
          )}
          onClick={handleClick}
        >
          {submitted ? (
            <div
              className="pointer-events-auto h-6 w-6 animate-spin cursor-pointer rounded-sm bg-foreground"
              style={{ animationDuration: "3s" }}
            />
          ) : (
            <Mic className="h-6 w-6 text-muted-foreground" />
          )}
        </button>

        <span
          className={cn(
            "font-mono text-sm transition-opacity duration-300",
            submitted
              ? "text-muted-foreground"
              : "text-muted-foreground/30"
          )}
        >
          {formatTime(time)}
        </span>

        <div className="flex h-4 w-64 items-center justify-center gap-0.5">
          {[...Array(48)].map((_, i) => (
            <div
              key={`bar-${i}`}
              className={cn(
                "w-0.5 rounded-full transition-all duration-300",
                submitted
                  ? "animate-pulse bg-foreground/50"
                  : "h-1 bg-foreground/10"
              )}
              style={
                submitted && isClient
                  ? {
                      height: `${20 + Math.random() * 80}%`,
                      animationDelay: `${i * 0.05}s`,
                    }
                  : undefined
              }
            />
          ))}
        </div>

        <p className="h-4 text-xs text-muted-foreground">
          {submitted ? "Listening..." : "Click to speak"}
        </p>
      </div>
    </div>
  );
}

/* ─── Glass card styling ─── */

const cardClasses = cn(
  "group relative flex h-full flex-col gap-4 rounded-xl p-5",
  "border border-border/60",
  "bg-gradient-to-b from-background/60 via-background/40 to-background/30",
  "shadow-[0_4px_20px_rgb(0,0,0,0.04)] backdrop-blur-[4px]",
  "transition-all duration-500 ease-out",
  "before:absolute before:inset-0 before:rounded-xl before:bg-gradient-to-b before:from-white/10 before:via-white/20 before:to-transparent before:opacity-100 before:transition-opacity before:duration-500",
  "after:absolute after:inset-0 after:z-[-1] after:rounded-xl after:bg-card/70",
  "hover:border-border/80 hover:shadow-[0_8px_30px_rgb(0,0,0,0.06)] hover:backdrop-blur-[6px]",
  "dark:shadow-[0_4px_20px_rgb(0,0,0,0.2)]",
  "dark:hover:shadow-[0_8px_30px_rgb(0,0,0,0.3)]",
  "dark:before:from-black/10 dark:before:via-black/20 dark:before:to-transparent",
  "dark:after:bg-card/70"
);

/* ─── Bento Card with 3D tilt ─── */

function BentoCard({ item }: { item: BentoItem }) {
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const rotateX = useTransform(y, [-100, 100], [2, -2]);
  const rotateY = useTransform(x, [-100, 100], [-2, 2]);

  function handleMouseMove(event: React.MouseEvent<HTMLDivElement>) {
    const rect = event.currentTarget.getBoundingClientRect();
    const mouseX = event.clientX - rect.left;
    const mouseY = event.clientY - rect.top;
    x.set((mouseX / rect.width - 0.5) * 100);
    y.set((mouseY / rect.height - 0.5) * 100);
  }

  function handleMouseLeave() {
    x.set(0);
    y.set(0);
  }

  return (
    <motion.div
      className="h-full"
      variants={fadeInUp}
      whileHover={{ y: -5 }}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{
        rotateX,
        rotateY,
        transformStyle: "preserve-3d",
      }}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
    >
      <div className={cardClasses}>
        <div
          className="relative z-10 flex h-full flex-col gap-3"
          style={{ transform: "translateZ(20px)" }}
        >
          <div className="flex flex-1 flex-col space-y-2">
            <h3 className="text-xl font-semibold tracking-tight text-foreground">
              {item.title}
            </h3>
            <p className="text-sm tracking-tight text-muted-foreground">
              {item.description}
            </p>

            {item.feature === "spotlight" && item.spotlightItems && (
              <SpotlightFeature items={item.spotlightItems} />
            )}
            {item.feature === "typing" && item.typingText && (
              <TypingCodeFeature text={item.typingText} />
            )}
            {item.feature === "icons" && <IconsFeature />}
          </div>
        </div>
      </div>
    </motion.div>
  );
}

/* ─── Section ─── */

export function FourPillars() {
  return (
    <section
      id="engines"
      className="relative overflow-hidden px-6 pt-12 pb-24 md:pt-16 md:pb-32"
    >
      <div className="mx-auto max-w-6xl">
        <motion.div
          className="grid gap-6"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={staggerContainer}
        >
          {/* Row 1: Spotlight (1 col) + Code (2 cols) */}
          <div className="grid gap-6 md:grid-cols-3">
            <motion.div className="md:col-span-1" variants={fadeInUp}>
              <BentoCard item={bentoItems[0]} />
            </motion.div>
            <motion.div className="md:col-span-2" variants={fadeInUp}>
              <BentoCard item={bentoItems[1]} />
            </motion.div>
          </div>

          {/* Row 2: Icons (1 col) + Voice demo (1 col) */}
          <div className="grid gap-6 md:grid-cols-2">
            <motion.div className="md:col-span-1" variants={fadeInUp}>
              <BentoCard item={bentoItems[2]} />
            </motion.div>
            <motion.div
              className="md:col-span-1"
              variants={fadeInUp}
            >
              <div className={cardClasses}>
                <div
                  className="relative z-10"
                  style={{ transform: "translateZ(20px)" }}
                >
                  <h3 className="text-xl font-semibold tracking-tight text-foreground">
                    Try it yourself
                  </h3>
                  <p className="mt-1 text-sm tracking-tight text-muted-foreground">
                    Voice to text, right here. No download, no account.
                  </p>
                  <VoiceDemo />
                </div>
              </div>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
