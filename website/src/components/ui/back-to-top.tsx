"use client";

import { useState, useEffect } from "react";
import { AnimatePresence, motion, useScroll } from "motion/react";
import { useLenis } from "lenis/react";
import { ArrowUp } from "lucide-react";

export function BackToTop() {
  const [isVisible, setIsVisible] = useState(false);
  const { scrollY } = useScroll();
  const lenis = useLenis();

  useEffect(() => {
    const unsubscribe = scrollY.on("change", (latest) => {
      setIsVisible(latest > window.innerHeight);
    });
    return unsubscribe;
  }, [scrollY]);

  const handleClick = () => {
    if (lenis) {
      lenis.scrollTo(0);
    } else {
      window.scrollTo({ top: 0, behavior: "smooth" });
    }
  };

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.button
          key="back-to-top"
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 8 }}
          transition={{ duration: 0.3, ease: "easeOut" }}
          whileHover={{ scale: 1.05 }}
          onClick={handleClick}
          aria-label="Scroll to top"
          className="group fixed bottom-6 right-6 z-40 flex size-10 cursor-pointer items-center justify-center rounded-xl border border-border bg-background/80 shadow-sm backdrop-blur-md transition-colors hover:text-foreground"
        >
          <ArrowUp className="size-4 text-muted-foreground transition-colors group-hover:text-foreground" />
        </motion.button>
      )}
    </AnimatePresence>
  );
}
