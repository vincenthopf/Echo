import { createMDX } from 'fumadocs-mdx/next';
import { initOpenNextCloudflareForDev } from '@opennextjs/cloudflare';

initOpenNextCloudflareForDev();

/** @type {import('next').NextConfig} */
const config = {
  images: {
    unoptimized: true,
  },
  experimental: {
    optimizePackageImports: ['motion', 'lucide-react', '@radix-ui/react-icons'],
  },
};

const withMDX = createMDX();

export default withMDX(config);
