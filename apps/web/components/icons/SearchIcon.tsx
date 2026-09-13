import React from "react";

interface SearchIconProps {
  size?: number | string;
  className?: string;
}

const svgMarkup = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" preserveAspectRatio="xMidYMid meet" fill="none" width="100%" height="100%">
  <rect x="0" y="0" width="24" height="24" rx="2.250" ry="2.250" fill="transparent"/>
  <g transform="translate(0.75, 0.75) scale(0.9375)">
    <g transform="translate(12, 12) rotate(0) scale(1, 1) translate(-12, -12)" stroke="#F4CB00" fill="#111111" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <g class="icon-anim-container icon-anim-group">
        <path d="M20.9999 21.0002L16.6599 16.6602" stroke="#111111"/>
<path d="M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 19 11Z" fill="#F4CB00"/>
      </g>
    </g>
  </g>
</svg>`;

export function SearchIcon({
  size = 128,
  className = "",
}: SearchIconProps) {
  return (
    <span
      className={className}
      style={{
        display: "inline-flex",
        width: size,
        height: size,
        lineHeight: 0,
      }}
      dangerouslySetInnerHTML={{ __html: svgMarkup }}
    />
  );
}

export default SearchIcon;