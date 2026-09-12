import { Navbar } from "@/components/navbar";
import { Hero } from "@/components/hero";
import { BentoFeatures } from "@/components/bento-features";
import { EditorialSections } from "@/components/editorial-sections";
import { CommunitySection } from "@/components/community-section";
import { Footer } from "@/components/footer";

export default function Home() {
  return (
    <main className="paper-page">
      <Navbar />
      <Hero />
      <BentoFeatures />
      <EditorialSections />
      <CommunitySection />
      <Footer />
    </main>
  );
}
