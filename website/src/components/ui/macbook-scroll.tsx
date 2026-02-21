"use client";

import React, { useEffect, useRef, useState } from "react";
import {
  motion,
  type MotionValue,
  useScroll,
  useTransform,
} from "motion/react";
import { cn } from "@/lib/utils";

interface MacbookScrollProps {
  src?: string;
  showGradient?: boolean;
  title?: React.ReactNode;
  badge?: React.ReactNode;
}

export function MacbookScroll({
  src,
  showGradient = true,
  title,
  badge,
}: MacbookScrollProps) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  });

  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    if (window && window.innerWidth < 768) {
      setIsMobile(true);
    }
  }, []);

  const scaleX = useTransform(
    scrollYProgress,
    [0, 0.3],
    [1.2, isMobile ? 1 : 1.5]
  );
  const scaleY = useTransform(
    scrollYProgress,
    [0, 0.3],
    [0.6, isMobile ? 1 : 1.5]
  );
  const translate = useTransform(scrollYProgress, [0, 1], [0, 1500]);
  const rotate = useTransform(
    scrollYProgress,
    [0.1, 0.12, 0.3],
    [-28, -28, 0]
  );
  const textTransform = useTransform(scrollYProgress, [0, 0.3], [0, 100]);
  const textOpacity = useTransform(scrollYProgress, [0, 0.2], [1, 0]);

  // Mobile: simple scale + fade instead of expensive 3D transforms
  const mobileScale = useTransform(scrollYProgress, [0, 0.3], [0.92, 1]);
  const mobileOpacity = useTransform(scrollYProgress, [0, 0.15], [0.7, 1]);

  if (isMobile) {
    return (
      <div
        ref={ref}
        className="flex min-h-[120vh] flex-shrink-0 flex-col items-center justify-start px-4 pb-0 pt-24"
      >
        {title && (
          <motion.div
            style={{ translateY: textTransform, opacity: textOpacity }}
            className="mb-10 text-center"
          >
            {title}
          </motion.div>
        )}

        <motion.div
          className="scale-[0.55] transform sm:scale-75"
          style={{
            scale: mobileScale,
            opacity: mobileOpacity,
            willChange: "transform, opacity",
          }}
        >
          {/* Screen — static, no 3D transforms */}
          <div className="relative">
            <div className="h-96 w-[32rem] rounded-2xl bg-[#010101] p-2">
              <div className="absolute inset-0 rounded-lg bg-[#272729]" />
              {src && (
                <img
                  src={src}
                  alt="Echo app screenshot"
                  className="relative h-full w-full rounded-lg object-cover object-left-top"
                  loading="lazy"
                />
              )}
            </div>
          </div>

          {/* MacBook base */}
          <div className="relative -z-10 h-[22rem] w-[32rem] overflow-hidden rounded-2xl bg-gray-200 dark:bg-[#272729]">
            <div className="relative h-10 w-full">
              <div className="absolute inset-x-0 mx-auto h-4 w-[80%] bg-[#050505]" />
            </div>
            <div className="relative flex">
              <div className="mx-auto h-full w-[10%] overflow-hidden">
                <SpeakerGrid />
              </div>
              <div className="mx-auto h-full w-[80%]">
                <Keypad />
              </div>
              <div className="mx-auto h-full w-[10%] overflow-hidden">
                <SpeakerGrid />
              </div>
            </div>
            <div
              className="mx-auto my-1 h-32 w-[40%] rounded-xl"
              style={{ boxShadow: "0px 0px 1px 1px #00000020 inset" }}
            />
            <div className="absolute inset-x-0 bottom-0 mx-auto h-2 w-20 rounded-tl-3xl rounded-tr-3xl bg-gradient-to-t from-[#272729] to-[#050505]" />
            {showGradient && (
              <div className="absolute inset-x-0 bottom-0 z-50 h-40 w-full bg-gradient-to-t from-white via-white to-transparent dark:from-black dark:via-black" />
            )}
            {badge && <div className="absolute bottom-4 left-4">{badge}</div>}
          </div>
        </motion.div>
      </div>
    );
  }

  return (
    <div
      ref={ref}
      className="flex min-h-[200vh] flex-shrink-0 flex-col items-center justify-start px-0 pb-80 pt-40 [perspective:800px]"
    >
      {title && (
        <motion.div
          style={{ translateY: textTransform, opacity: textOpacity }}
          className="mb-20 text-center"
        >
          {title}
        </motion.div>
      )}

      {/* MacBook visual */}
      <div className="scale-100 transform">
        <Lid
          src={src}
          scaleX={scaleX}
          scaleY={scaleY}
          rotate={rotate}
          translate={translate}
        />

        {/* MacBook base */}
        <div className="relative -z-10 h-[22rem] w-[32rem] overflow-hidden rounded-2xl bg-gray-200 dark:bg-[#272729]">
          {/* Top edge under hinge */}
          <div className="relative h-10 w-full">
            <div className="absolute inset-x-0 mx-auto h-4 w-[80%] bg-[#050505]" />
          </div>

          <div className="relative flex">
            <div className="mx-auto h-full w-[10%] overflow-hidden">
              <SpeakerGrid />
            </div>
            <div className="mx-auto h-full w-[80%]">
              <Keypad />
            </div>
            <div className="mx-auto h-full w-[10%] overflow-hidden">
              <SpeakerGrid />
            </div>
          </div>

          {/* Trackpad */}
          <div
            className="mx-auto my-1 h-32 w-[40%] rounded-xl"
            style={{ boxShadow: "0px 0px 1px 1px #00000020 inset" }}
          />

          {/* Bottom notch */}
          <div className="absolute inset-x-0 bottom-0 mx-auto h-2 w-20 rounded-tl-3xl rounded-tr-3xl bg-gradient-to-t from-[#272729] to-[#050505]" />

          {showGradient && (
            <div className="absolute inset-x-0 bottom-0 z-50 h-40 w-full bg-gradient-to-t from-white via-white to-transparent dark:from-black dark:via-black" />
          )}

          {badge && <div className="absolute bottom-4 left-4">{badge}</div>}
        </div>
      </div>
    </div>
  );
}

/* ─── Lid ──────────────────────────────────────────────────────── */

function Lid({
  src,
  scaleX,
  scaleY,
  rotate,
  translate,
}: {
  src?: string;
  scaleX: MotionValue<number>;
  scaleY: MotionValue<number>;
  rotate: MotionValue<number>;
  translate: MotionValue<number>;
}) {
  return (
    <div className="relative [perspective:800px]">
      {/* Back of lid (visible when tilted) */}
      <div
        style={{
          transform: "perspective(800px) rotateX(-25deg) translateZ(0px)",
          transformOrigin: "bottom",
          transformStyle: "preserve-3d",
        }}
        className="relative h-[12rem] w-[32rem] rounded-2xl bg-[#010101] p-2"
      >
        <div
          style={{ boxShadow: "0px 2px 0px 2px #171717 inset" }}
          className="absolute inset-0 flex items-center justify-center rounded-lg bg-[#010101]"
        >
          <span className="text-white">
            <LidLogo />
          </span>
        </div>
      </div>

      {/* Screen (animated open) */}
      <motion.div
        style={{
          scaleX,
          scaleY,
          rotateX: rotate,
          translateY: translate,
          transformStyle: "preserve-3d",
          transformOrigin: "top",
          willChange: "transform",
        }}
        className="absolute inset-0 h-96 w-[32rem] rounded-2xl bg-[#010101] p-2"
      >
        <div className="absolute inset-0 rounded-lg bg-[#272729]" />
        {src && (
          <img
            src={src}
            alt="Echo app screenshot"
            className="absolute inset-0 h-full w-full rounded-lg object-cover object-left-top"
            loading="lazy"
          />
        )}
      </motion.div>
    </div>
  );
}

/* ─── Logo on lid back ─────────────────────────────────────────── */

function LidLogo() {
  return (
    <svg
      width="60"
      height="60"
      viewBox="0 0 60 60"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className="h-7 w-7 opacity-80"
    >
      <circle cx="30" cy="30" r="24" stroke="white" strokeWidth="2" fill="none" opacity="0.3" />
      <circle cx="30" cy="30" r="16" stroke="white" strokeWidth="2" fill="none" opacity="0.5" />
      <circle cx="30" cy="30" r="8" fill="white" opacity="0.7" />
    </svg>
  );
}

/* ─── Speaker Grille ───────────────────────────────────────────── */

function SpeakerGrid() {
  return (
    <div
      className="mt-2 flex h-40 gap-[2px] px-[0.5px]"
      style={{
        backgroundImage:
          "radial-gradient(circle, #08080A 0.5px, transparent 0.5px)",
        backgroundSize: "3px 3px",
      }}
    />
  );
}

/* ─── Key Button ───────────────────────────────────────────────── */

function KBtn({
  children,
  className,
  childrenClassName,
  backlit = true,
}: {
  children?: React.ReactNode;
  className?: string;
  childrenClassName?: string;
  backlit?: boolean;
}) {
  return (
    <div
      className={cn(
        "rounded-[4px] p-[0.5px]",
        backlit && "bg-white/[0.2] shadow-xl shadow-white"
      )}
    >
      <div
        className={cn(
          "flex h-6 w-6 items-center justify-center rounded-[3.5px] bg-[#0A090D]",
          className
        )}
        style={{
          boxShadow:
            "0px -0.5px 2px 0 #0D0D0F inset, -0.5px 0px 2px 0 #0D0D0F inset",
        }}
      >
        <div
          className={cn(
            "flex w-full flex-col items-center justify-center text-[5px] text-neutral-200",
            childrenClassName,
            backlit && "text-white"
          )}
        >
          {children}
        </div>
      </div>
    </div>
  );
}

/* ─── Keypad ───────────────────────────────────────────────────── */

function Keypad() {
  return (
    <div className="mx-1 flex h-full flex-col justify-start gap-[2px] rounded-md p-1">
      {/* Function row */}
      <Row>
        <KBtn className="w-10 items-start" childrenClassName="items-start">
          <span className="block">esc</span>
        </KBtn>
        <KBtn>
          <IconBrightnessDown />
        </KBtn>
        <KBtn>
          <IconBrightnessUp />
        </KBtn>
        <KBtn>
          <IconGrid />
        </KBtn>
        <KBtn>
          <IconSearch />
        </KBtn>
        <KBtn>
          <IconMic />
        </KBtn>
        <KBtn>
          <IconMoon />
        </KBtn>
        <KBtn>
          <IconRewind />
        </KBtn>
        <KBtn>
          <IconPlayPause />
        </KBtn>
        <KBtn>
          <IconForward />
        </KBtn>
        <KBtn>
          <IconVolumeMute />
        </KBtn>
        <KBtn>
          <IconVolumeDown />
        </KBtn>
        <KBtn>
          <IconVolumeUp />
        </KBtn>
        <KBtn>
          <IconPower />
        </KBtn>
      </Row>

      {/* Number row */}
      <Row>
        <KBtn>
          <span className="block">~</span>
          <span className="block">`</span>
        </KBtn>
        <KBtn>
          <span className="block">!</span>
          <span className="block">1</span>
        </KBtn>
        <KBtn>
          <span className="block">@</span>
          <span className="block">2</span>
        </KBtn>
        <KBtn>
          <span className="block">#</span>
          <span className="block">3</span>
        </KBtn>
        <KBtn>
          <span className="block">$</span>
          <span className="block">4</span>
        </KBtn>
        <KBtn>
          <span className="block">%</span>
          <span className="block">5</span>
        </KBtn>
        <KBtn>
          <span className="block">^</span>
          <span className="block">6</span>
        </KBtn>
        <KBtn>
          <span className="block">&amp;</span>
          <span className="block">7</span>
        </KBtn>
        <KBtn>
          <span className="block">*</span>
          <span className="block">8</span>
        </KBtn>
        <KBtn>
          <span className="block">(</span>
          <span className="block">9</span>
        </KBtn>
        <KBtn>
          <span className="block">)</span>
          <span className="block">0</span>
        </KBtn>
        <KBtn>
          <span className="block">&mdash;</span>
          <span className="block">-</span>
        </KBtn>
        <KBtn>
          <span className="block">+</span>
          <span className="block">=</span>
        </KBtn>
        <KBtn className="w-10" childrenClassName="items-end">
          <span className="block">delete</span>
        </KBtn>
      </Row>

      {/* QWERTY row */}
      <Row>
        <KBtn className="w-10" childrenClassName="items-start">
          <span className="block">tab</span>
        </KBtn>
        <KBtn><span>Q</span></KBtn>
        <KBtn><span>W</span></KBtn>
        <KBtn><span>E</span></KBtn>
        <KBtn><span>R</span></KBtn>
        <KBtn><span>T</span></KBtn>
        <KBtn><span>Y</span></KBtn>
        <KBtn><span>U</span></KBtn>
        <KBtn><span>I</span></KBtn>
        <KBtn><span>O</span></KBtn>
        <KBtn><span>P</span></KBtn>
        <KBtn>
          <span className="block">&#123;</span>
          <span className="block">[</span>
        </KBtn>
        <KBtn>
          <span className="block">&#125;</span>
          <span className="block">]</span>
        </KBtn>
        <KBtn>
          <span className="block">|</span>
          <span className="block">\</span>
        </KBtn>
      </Row>

      {/* ASDF row */}
      <Row>
        <KBtn className="w-[2.8rem]" childrenClassName="items-start">
          <span className="block">caps lock</span>
        </KBtn>
        <KBtn><span>A</span></KBtn>
        <KBtn><span>S</span></KBtn>
        <KBtn><span>D</span></KBtn>
        <KBtn><span>F</span></KBtn>
        <KBtn><span>G</span></KBtn>
        <KBtn><span>H</span></KBtn>
        <KBtn><span>J</span></KBtn>
        <KBtn><span>K</span></KBtn>
        <KBtn><span>L</span></KBtn>
        <KBtn>
          <span className="block">:</span>
          <span className="block">;</span>
        </KBtn>
        <KBtn>
          <span className="block">&quot;</span>
          <span className="block">&apos;</span>
        </KBtn>
        <KBtn className="w-[2.85rem]" childrenClassName="items-end">
          <span className="block">return</span>
        </KBtn>
      </Row>

      {/* ZXCV row */}
      <Row>
        <KBtn className="w-[3.65rem]" childrenClassName="items-start">
          <span className="block">shift</span>
        </KBtn>
        <KBtn><span>Z</span></KBtn>
        <KBtn><span>X</span></KBtn>
        <KBtn><span>C</span></KBtn>
        <KBtn><span>V</span></KBtn>
        <KBtn><span>B</span></KBtn>
        <KBtn><span>N</span></KBtn>
        <KBtn><span>M</span></KBtn>
        <KBtn>
          <span className="block">&lt;</span>
          <span className="block">,</span>
        </KBtn>
        <KBtn>
          <span className="block">&gt;</span>
          <span className="block">.</span>
        </KBtn>
        <KBtn>
          <span className="block">?</span>
          <span className="block">/</span>
        </KBtn>
        <KBtn className="w-[3.65rem]" childrenClassName="items-end">
          <span className="block">shift</span>
        </KBtn>
      </Row>

      {/* Bottom row */}
      <Row>
        <KBtn childrenClassName="items-start">
          <span className="block">fn</span>
        </KBtn>
        <KBtn childrenClassName="items-start">
          <span className="block text-[4px]">control</span>
        </KBtn>
        <KBtn childrenClassName="items-start">
          <span className="block text-[4px]">option</span>
        </KBtn>
        <KBtn className="w-8" childrenClassName="items-start">
          <span className="block text-[4px]">&#8984;</span>
        </KBtn>
        <KBtn className="w-[8.2rem] !rounded-[4px]" backlit={false}>
          <span />
        </KBtn>
        <KBtn className="w-8" childrenClassName="items-end">
          <span className="block text-[4px]">&#8984;</span>
        </KBtn>
        <KBtn childrenClassName="items-end">
          <span className="block text-[4px]">option</span>
        </KBtn>
        {/* Arrow keys */}
        <div className="flex flex-col items-center justify-end gap-[1px]">
          <KBtn className="h-3">
            <IconArrowUp />
          </KBtn>
          <div className="flex gap-[1px]">
            <KBtn className="h-3">
              <IconArrowLeft />
            </KBtn>
            <KBtn className="h-3">
              <IconArrowDown />
            </KBtn>
            <KBtn className="h-3">
              <IconArrowRight />
            </KBtn>
          </div>
        </div>
      </Row>
    </div>
  );
}

function Row({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex w-full flex-shrink-0 gap-[2px]">{children}</div>
  );
}

/* ─── Key Icons ────────────────────────────────────────────────── */

const iconProps = {
  width: 12,
  height: 12,
  viewBox: "0 0 24 24",
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 1.5,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
};

function IconBrightnessDown() {
  return (
    <svg {...iconProps}>
      <circle cx="12" cy="12" r="4" />
      <path d="M12 4v1M12 19v1M4 12H3M21 12h1M6.3 6.3l-.7-.7M18.4 18.4l.7.7M6.3 17.7l-.7.7M18.4 5.6l.7-.7" />
    </svg>
  );
}

function IconBrightnessUp() {
  return (
    <svg {...iconProps} strokeWidth={2}>
      <circle cx="12" cy="12" r="4" />
      <path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
    </svg>
  );
}

function IconGrid() {
  return (
    <svg {...iconProps}>
      <rect x="3" y="3" width="7" height="7" rx="1" />
      <rect x="14" y="3" width="7" height="7" rx="1" />
      <rect x="3" y="14" width="7" height="7" rx="1" />
      <rect x="14" y="14" width="7" height="7" rx="1" />
    </svg>
  );
}

function IconSearch() {
  return (
    <svg {...iconProps}>
      <circle cx="11" cy="11" r="8" />
      <path d="m21 21-4.3-4.3" />
    </svg>
  );
}

function IconMic() {
  return (
    <svg {...iconProps}>
      <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z" />
      <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
      <line x1="12" x2="12" y1="19" y2="22" />
    </svg>
  );
}

function IconMoon() {
  return (
    <svg {...iconProps}>
      <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
    </svg>
  );
}

function IconRewind() {
  return (
    <svg {...iconProps}>
      <polygon points="11 19 2 12 11 5" />
      <polygon points="22 19 13 12 22 5" />
    </svg>
  );
}

function IconPlayPause() {
  return (
    <svg {...iconProps}>
      <polygon points="5 3 5 21 12 14 12 3" />
      <line x1="17" x2="17" y1="4" y2="20" />
      <line x1="21" x2="21" y1="4" y2="20" />
    </svg>
  );
}

function IconForward() {
  return (
    <svg {...iconProps}>
      <polygon points="13 19 22 12 13 5" />
      <polygon points="2 19 11 12 2 5" />
    </svg>
  );
}

function IconVolumeMute() {
  return (
    <svg {...iconProps}>
      <polygon points="11 5 6 9 2 9 2 15 6 15 11 19" />
      <line x1="23" x2="17" y1="9" y2="15" />
      <line x1="17" x2="23" y1="9" y2="15" />
    </svg>
  );
}

function IconVolumeDown() {
  return (
    <svg {...iconProps}>
      <polygon points="11 5 6 9 2 9 2 15 6 15 11 19" />
      <path d="M15.5 8.5a5 5 0 0 1 0 7" />
    </svg>
  );
}

function IconVolumeUp() {
  return (
    <svg {...iconProps}>
      <polygon points="11 5 6 9 2 9 2 15 6 15 11 19" />
      <path d="M15.5 8.5a5 5 0 0 1 0 7" />
      <path d="M19.1 4.9a10 10 0 0 1 0 14.2" />
    </svg>
  );
}

function IconPower() {
  return (
    <svg {...iconProps}>
      <path d="M12 2v10" />
      <path d="M18.4 6.6a9 9 0 1 1-12.8 0" />
    </svg>
  );
}

function IconArrowUp() {
  return (
    <svg {...iconProps} width={8} height={8}>
      <path d="m18 15-6-6-6 6" />
    </svg>
  );
}

function IconArrowDown() {
  return (
    <svg {...iconProps} width={8} height={8}>
      <path d="m6 9 6 6 6-6" />
    </svg>
  );
}

function IconArrowLeft() {
  return (
    <svg {...iconProps} width={8} height={8}>
      <path d="m15 18-6-6 6-6" />
    </svg>
  );
}

function IconArrowRight() {
  return (
    <svg {...iconProps} width={8} height={8}>
      <path d="m9 18 6-6-6-6" />
    </svg>
  );
}
