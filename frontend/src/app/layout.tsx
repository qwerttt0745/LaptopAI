import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
    title: "LaptopAI",
    description: "AI-powered laptop recommendations",
};

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <html lang="en">
            <body>{children}</body>
        </html>
    );
}