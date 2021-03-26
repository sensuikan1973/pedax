import Translate, { translate } from '@docusaurus/Translate'
import useBaseUrl from '@docusaurus/useBaseUrl'
import useDocusaurusContext from '@docusaurus/useDocusaurusContext'
import Layout from '@theme/Layout'
import clsx from 'clsx'
import React from 'react'

import styles from './styles.module.css'

const features = [
  {
    title: translate({ id: "analysis_mode_board_title" }),
    imageUrl: translate({ id: "analysis_mode_board_view" }),
    description: translate({ id: "analysis_mode_board_description" }),
  },
  {
    title: translate({ id: "custome_options_title" }),
    imageUrl: translate({ id: "custome_options_view" }),
    description: translate({ id: "custome_options_description" }),
  },
];

function Feature({imageUrl, title, description}) {
  const imgUrl = useBaseUrl(imageUrl);
  return (
    <div className={clsx('col col--6', styles.feature)}>
      {imgUrl && (
        <div className="text--center">
          <img className={styles.featureImage} src={imgUrl} alt={title} />
        </div>
      )}
      <h3 className="text--center">{title}</h3>
      <p className="text--center">{description}</p>
    </div>
  );
}

export default function Home() {
  const context = useDocusaurusContext();
  const {siteConfig = {}} = context;
  return (
    <Layout
      title={ translate({ id: "installation_page_title" }) } /*`${siteConfig.title}`*/
      description={`${translate({ id: "pedax_description" })} <head />`}>
      <header className={clsx('hero hero--primary', styles.heroBanner)}>
        <div className="container">
          <h1 className="hero__title">{siteConfig.title}</h1>
          <p className="hero__subtitle">{translate({ id: "pedax_description" })}</p>
          <section className="storeImages">
            <a href="TODO: changeme"><img className={styles.storeImage} src={ translate({ id: "mac_app_store_badge" }) }/></a>
            <a href="TODO: changeme"><img className={styles.storeImage} src={ translate({ id: "microsoft_store_badge" }) }/></a>
          </section>
        </div>
      </header>
      <main>
        {features && features.length > 0 && (
          <section className={styles.features}>
            <div className="container">
              <div className="row">
                {features.map((props, idx) => (
                  <Feature key={idx} {...props} />
                ))}
              </div>
            </div>
          </section>
        )}
      </main>
    </Layout>
  );
}
