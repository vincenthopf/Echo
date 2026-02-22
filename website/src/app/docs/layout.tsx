import { DocsLayout } from 'fumadocs-ui/layouts/docs';
import type { ReactNode } from 'react';
import Image from 'next/image';
import { source } from '@/lib/source';

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <DocsLayout
      tree={source.pageTree}
      nav={{
        title: (
          <div className="flex items-center gap-2">
            <Image
              src="/app-icon.webp"
              alt="Echo"
              width={24}
              height={24}
              className="rounded-md"
            />
            <span className="font-semibold">Echo Docs</span>
          </div>
        ),
        url: '/',
      }}
    >
      {children}
    </DocsLayout>
  );
}
