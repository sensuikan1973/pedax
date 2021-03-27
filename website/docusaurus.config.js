/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: 'pedax',
  titleDelimiter: '🍵',
  tagline: 'Reversi Board with edax',
  url: 'https://sensuikan1973.github.io',
  baseUrl: '/pedax/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'sensuikan1973',
  projectName: 'pedax',
  i18n: {
    defaultLocale: 'ja',
    locales: ['ja', 'en'],
  },
  themeConfig: {
    image: 'img/pedax_og.png',
    navbar: {
      title: 'pedax',
      logo: { alt: 'pedax Logo', src: 'img/logo.svg' },
      items: [
        {
          href: 'https://github.com/sensuikan1973/pedax',
          label: 'GitHub',
          position: 'right',
        },
        {
          type: 'localeDropdown',
          position: 'left',
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `Copyright © ${new Date().getFullYear()} Naoki Shimizu. Built with Docusaurus.`,
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
