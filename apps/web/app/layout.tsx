import type { Metadata } from "next";
import { Inter, Luckiest_Guy } from "next/font/google";
import { Analytics } from "@vercel/analytics/next";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

const luckiestGuy = Luckiest_Guy({
  subsets: ["latin"],
  weight: "400",
  variable: "--font-luckiest-guy",
});

export const metadata: Metadata = {
  title: "Keihatsu | The social manhwa reader",
  description:
    "Search across extensions, save chapters offline, and connect with fellow readers in a cross-platform social manhwa reader.",
  icons: {
    icon: [
      {
        url: "/icon.svg",
        type: "image/svg+xml",
      },
    ],
    // apple: "/apple-icon.png",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.variable} ${luckiestGuy.variable}`}>
        {children}
        <Analytics />
      </body>
    </html>
  );
}
