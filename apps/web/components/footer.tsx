import Image from "next/image";

const downloadUrl =
  "https://github.com/grvt8/Keihatsu/releases/download/v1.0.0/keihatsu-v1.0.0.apk";

const leftGroups = [
  {
    title: "EXPLORE",
    links: [
      ["Reader", "#reader"],
      ["Features", "#features"],
      ["Download", downloadUrl],
      ["Themes", "#features"],
    ],
  },
  {
    title: "COMMUNITY",
    links: [
      ["Comments", "#community"],
      ["Discord", "https://discord.gg/8cu84svT"],
      ["Roadmap", "https://github.com/grvt8/Keihatsu"],
      ["Contribute", "https://github.com/grvt8/Keihatsu"],
    ],
  },
];

const rightGroups = [
  {
    title: "PROJECT",
    links: [
      ["GitHub", "https://github.com/grvt8/Keihatsu"],
      ["Releases", "https://github.com/grvt8/Keihatsu/releases"],
      ["Issues", "https://github.com/grvt8/Keihatsu/issues"],
      ["Source code", "https://github.com/grvt8/Keihatsu"],
    ],
  },
  {
    title: "LEGAL",
    links: [
      ["Privacy", "#"],
      ["Terms", "#"],
      ["MIT license", "https://github.com/grvt8/Keihatsu"],
      ["Contact", "https://discord.gg/8cu84svT"],
    ],
  },
];

function FooterLinks({
  groups,
  side,
}: {
  groups: typeof leftGroups;
  side: "left" | "right";
}) {
  return (
    <div className="mascot-footer__links" data-side={side}>
      {groups.map((group) => (
        <nav key={group.title} aria-label={group.title}>
          <h3>{group.title}</h3>
          {group.links.map(([label, href]) => (
            <a key={label} href={href} download={label === "Download"}>
              {label}
            </a>
          ))}
        </nav>
      ))}
    </div>
  );
}

export function Footer() {
  return (
    <footer className="mascot-footer">
      <div className="mascot-footer__frame">
        <div className="mascot-footer__panel">
          <Image
            className="mascot-footer__mascot"
            src="/keihatsu-footer-mascot.png"
            alt="Keihatsu rabbit mascot"
            width={820}
            height={888}
            sizes="820px"
          />
          <span className="mascot-footer__wash" aria-hidden="true" />

          <a
            className="mascot-footer__brand font-comic tracking-tight"
            href="#reader"
          >
            <Image src="/logo.png" alt="" width={44} height={44} />
            <span>KEIHATSU</span>
          </a>

          <FooterLinks groups={leftGroups} side="left" />
          <FooterLinks groups={rightGroups} side="right" />

          <a className="mascot-footer__action" href={downloadUrl} download>
            DOWNLOAD · READ · CONNECT ↗
          </a>
        </div>
      </div>
    </footer>
  );
}
