(self.webpackChunkpedax=self.webpackChunkpedax||[]).push([[514],{3042:function(e,t,n){"use strict";n.r(t),n.d(t,{default:function(){return je}});var a=n(7294),r=n(3905),o=n(6291),l=n(4814),c=n(6010),i=n(2822),s=n(3783),u=n(5537),d=n(7462),m=function(e){return a.createElement("svg",(0,d.Z)({width:"20",height:"20","aria-hidden":"true"},e),a.createElement("g",{fill:"#7a7a7a"},a.createElement("path",{d:"M9.992 10.023c0 .2-.062.399-.172.547l-4.996 7.492a.982.982 0 01-.828.454H1c-.55 0-1-.453-1-1 0-.2.059-.403.168-.551l4.629-6.942L.168 3.078A.939.939 0 010 2.528c0-.548.45-.997 1-.997h2.996c.352 0 .649.18.828.45L9.82 9.472c.11.148.172.347.172.55zm0 0"}),a.createElement("path",{d:"M19.98 10.023c0 .2-.058.399-.168.547l-4.996 7.492a.987.987 0 01-.828.454h-3c-.547 0-.996-.453-.996-1 0-.2.059-.403.168-.551l4.625-6.942-4.625-6.945a.939.939 0 01-.168-.55 1 1 0 01.996-.997h3c.348 0 .649.18.828.45l4.996 7.492c.11.148.168.347.168.55zm0 0"})))},p=n(5999),h=n(3366),f=n(9960),y=n(3919),v=n(541),b="menuLinkText_1J2g",g=["items"],k=["item"],E=["item","onItemClick","activePath","level"],C=["item","onItemClick","activePath","level"],Z=function e(t,n){return"link"===t.type?(0,i.Mg)(t.href,n):"category"===t.type&&t.items.some((function(t){return e(t,n)}))},T=(0,a.memo)((function(e){var t=e.items,n=(0,h.Z)(e,g);return a.createElement(a.Fragment,null,t.map((function(e,t){return a.createElement(_,(0,d.Z)({key:t,item:e},n))})))}));function _(e){var t=e.item,n=(0,h.Z)(e,k);switch(t.type){case"category":return 0===t.items.length?null:a.createElement(N,(0,d.Z)({item:t},n));case"link":default:return a.createElement(S,(0,d.Z)({item:t},n))}}function N(e){var t,n=e.item,r=e.onItemClick,o=e.activePath,l=e.level,s=(0,h.Z)(e,E),u=n.items,m=n.label,p=n.collapsible,f=n.className,y=Z(n,o),v=(0,i.uR)({initialState:function(){return!!p&&(!y&&n.collapsed)}}),g=v.collapsed,k=v.setCollapsed,C=v.toggleCollapsed;return function(e){var t=e.isActive,n=e.collapsed,r=e.setCollapsed,o=(0,i.D9)(t);(0,a.useEffect)((function(){t&&!o&&n&&r(!1)}),[t,o,n,r])}({isActive:y,collapsed:g,setCollapsed:k}),a.createElement("li",{className:(0,c.Z)(i.kM.docs.docSidebarItemCategory,i.kM.docs.docSidebarItemCategoryLevel(l),"menu__list-item",{"menu__list-item--collapsed":g},f)},a.createElement("a",(0,d.Z)({className:(0,c.Z)("menu__link",(t={"menu__link--sublist":p,"menu__link--active":p&&y},t[b]=!p,t)),onClick:p?function(e){e.preventDefault(),C()}:void 0,href:p?"#":void 0},s),m),a.createElement(i.zF,{lazy:!0,as:"ul",className:"menu__list",collapsed:g},a.createElement(T,{items:u,tabIndex:g?-1:0,onItemClick:r,activePath:o,level:l+1})))}function S(e){var t=e.item,n=e.onItemClick,r=e.activePath,o=e.level,l=(0,h.Z)(e,C),s=t.href,u=t.label,m=t.className,p=Z(t,r);return a.createElement("li",{className:(0,c.Z)(i.kM.docs.docSidebarItemLink,i.kM.docs.docSidebarItemLinkLevel(o),"menu__list-item",m),key:u},a.createElement(f.Z,(0,d.Z)({className:(0,c.Z)("menu__link",{"menu__link--active":p}),"aria-current":p?"page":void 0,to:s},(0,y.Z)(s)&&{onClick:n},l),(0,y.Z)(s)?u:a.createElement("span",null,u,a.createElement(v.Z,null))))}var x="sidebar_15mo",I="sidebarWithHideableNavbar_267A",j="sidebarHidden_2kNb",B="sidebarLogo_3h0W",L="menu_Bmed",A="menuWithAnnouncementBar_2WvA",M="collapseSidebarButton_1CGd",P="collapseSidebarButtonIcon_3E-R";function D(e){var t=e.onClick;return a.createElement("button",{type:"button",title:(0,p.I)({id:"theme.docs.sidebar.collapseButtonTitle",message:"Collapse sidebar",description:"The title attribute for collapse button of doc sidebar"}),"aria-label":(0,p.I)({id:"theme.docs.sidebar.collapseButtonAriaLabel",message:"Collapse sidebar",description:"The title attribute for collapse button of doc sidebar"}),className:(0,c.Z)("button button--secondary button--outline",M),onClick:t},a.createElement(m,{className:P}))}function w(e){var t,n,r=e.path,o=e.sidebar,l=e.onCollapse,s=e.isHidden,d=function(){var e=(0,i.nT)().isActive,t=(0,a.useState)(e),n=t[0],r=t[1];return(0,i.RF)((function(t){var n=t.scrollY;e&&r(0===n)}),[e]),e&&n}(),m=(0,i.LU)(),p=m.navbar.hideOnScroll,h=m.hideableSidebar;return a.createElement("div",{className:(0,c.Z)(x,(t={},t[I]=p,t[j]=s,t))},p&&a.createElement(u.Z,{tabIndex:-1,className:B}),a.createElement("nav",{className:(0,c.Z)("menu thin-scrollbar",L,(n={},n[A]=d,n))},a.createElement("ul",{className:(0,c.Z)(i.kM.docs.docSidebarMenu,"menu__list")},a.createElement(T,{items:o,activePath:r,level:1}))),h&&a.createElement(D,{onClick:l}))}var R=function(e){var t=e.toggleSidebar,n=e.sidebar,r=e.path;return a.createElement("ul",{className:(0,c.Z)(i.kM.docs.docSidebarMenu,"menu__list")},a.createElement(T,{items:n,activePath:r,onItemClick:function(){return t()},level:1}))};function O(e){return a.createElement(i.Cv,{component:R,props:e})}var F=a.memo(w),H=a.memo(O);function z(e){var t=(0,s.Z)(),n="desktop"===t||"ssr"===t,r="mobile"===t;return a.createElement(a.Fragment,null,n&&a.createElement(F,e),r&&a.createElement(H,e))}var W=n(2859),V={plain:{backgroundColor:"#2a2734",color:"#9a86fd"},styles:[{types:["comment","prolog","doctype","cdata","punctuation"],style:{color:"#6c6783"}},{types:["namespace"],style:{opacity:.7}},{types:["tag","operator","number"],style:{color:"#e09142"}},{types:["property","function"],style:{color:"#9a86fd"}},{types:["tag-id","selector","atrule-id"],style:{color:"#eeebff"}},{types:["attr-name"],style:{color:"#c4b9fe"}},{types:["boolean","string","entity","url","attr-value","keyword","control","directive","unit","statement","regex","at-rule","placeholder","variable"],style:{color:"#ffcc99"}},{types:["deleted"],style:{textDecorationLine:"line-through"}},{types:["inserted"],style:{textDecorationLine:"underline"}},{types:["italic"],style:{fontStyle:"italic"}},{types:["important","bold"],style:{fontWeight:"bold"}},{types:["important"],style:{color:"#c4b9fe"}}]},Y={Prism:n(7410).default,theme:V};function $(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function U(){return(U=Object.assign||function(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var a in n)Object.prototype.hasOwnProperty.call(n,a)&&(e[a]=n[a])}return e}).apply(this,arguments)}var J=/\r\n|\r|\n/,K=function(e){0===e.length?e.push({types:["plain"],content:"\n",empty:!0}):1===e.length&&""===e[0].content&&(e[0].content="\n",e[0].empty=!0)},G=function(e,t){var n=e.length;return n>0&&e[n-1]===t?e:e.concat(t)},q=function(e,t){var n=e.plain,a=Object.create(null),r=e.styles.reduce((function(e,n){var a=n.languages,r=n.style;return a&&!a.includes(t)||n.types.forEach((function(t){var n=U({},e[t],r);e[t]=n})),e}),a);return r.root=n,r.plain=U({},n,{backgroundColor:null}),r};function Q(e,t){var n={};for(var a in e)Object.prototype.hasOwnProperty.call(e,a)&&-1===t.indexOf(a)&&(n[a]=e[a]);return n}var X=function(e){function t(){for(var t=this,n=[],a=arguments.length;a--;)n[a]=arguments[a];e.apply(this,n),$(this,"getThemeDict",(function(e){if(void 0!==t.themeDict&&e.theme===t.prevTheme&&e.language===t.prevLanguage)return t.themeDict;t.prevTheme=e.theme,t.prevLanguage=e.language;var n=e.theme?q(e.theme,e.language):void 0;return t.themeDict=n})),$(this,"getLineProps",(function(e){var n=e.key,a=e.className,r=e.style,o=U({},Q(e,["key","className","style","line"]),{className:"token-line",style:void 0,key:void 0}),l=t.getThemeDict(t.props);return void 0!==l&&(o.style=l.plain),void 0!==r&&(o.style=void 0!==o.style?U({},o.style,r):r),void 0!==n&&(o.key=n),a&&(o.className+=" "+a),o})),$(this,"getStyleForToken",(function(e){var n=e.types,a=e.empty,r=n.length,o=t.getThemeDict(t.props);if(void 0!==o){if(1===r&&"plain"===n[0])return a?{display:"inline-block"}:void 0;if(1===r&&!a)return o[n[0]];var l=a?{display:"inline-block"}:{},c=n.map((function(e){return o[e]}));return Object.assign.apply(Object,[l].concat(c))}})),$(this,"getTokenProps",(function(e){var n=e.key,a=e.className,r=e.style,o=e.token,l=U({},Q(e,["key","className","style","token"]),{className:"token "+o.types.join(" "),children:o.content,style:t.getStyleForToken(o),key:void 0});return void 0!==r&&(l.style=void 0!==l.style?U({},l.style,r):r),void 0!==n&&(l.key=n),a&&(l.className+=" "+a),l})),$(this,"tokenize",(function(e,t,n,a){var r={code:t,grammar:n,language:a,tokens:[]};e.hooks.run("before-tokenize",r);var o=r.tokens=e.tokenize(r.code,r.grammar,r.language);return e.hooks.run("after-tokenize",r),o}))}return e&&(t.__proto__=e),t.prototype=Object.create(e&&e.prototype),t.prototype.constructor=t,t.prototype.render=function(){var e=this.props,t=e.Prism,n=e.language,a=e.code,r=e.children,o=this.getThemeDict(this.props),l=t.languages[n];return r({tokens:function(e){for(var t=[[]],n=[e],a=[0],r=[e.length],o=0,l=0,c=[],i=[c];l>-1;){for(;(o=a[l]++)<r[l];){var s=void 0,u=t[l],d=n[l][o];if("string"==typeof d?(u=l>0?u:["plain"],s=d):(u=G(u,d.type),d.alias&&(u=G(u,d.alias)),s=d.content),"string"==typeof s){var m=s.split(J),p=m.length;c.push({types:u,content:m[0]});for(var h=1;h<p;h++)K(c),i.push(c=[]),c.push({types:u,content:m[h]})}else l++,t.push(u),n.push(s),a.push(0),r.push(s.length)}l--,t.pop(),n.pop(),a.pop(),r.pop()}return K(c),i}(void 0!==l?this.tokenize(t,a,l,n):[a]),className:"prism-code language-"+n,style:void 0!==o?o.root:{},getLineProps:this.getLineProps,getTokenProps:this.getTokenProps})},t}(a.Component);var ee=n(7594),te=n.n(ee),ne={plain:{color:"#bfc7d5",backgroundColor:"#292d3e"},styles:[{types:["comment"],style:{color:"rgb(105, 112, 152)",fontStyle:"italic"}},{types:["string","inserted"],style:{color:"rgb(195, 232, 141)"}},{types:["number"],style:{color:"rgb(247, 140, 108)"}},{types:["builtin","char","constant","function"],style:{color:"rgb(130, 170, 255)"}},{types:["punctuation","selector"],style:{color:"rgb(199, 146, 234)"}},{types:["variable"],style:{color:"rgb(191, 199, 213)"}},{types:["class-name","attr-name"],style:{color:"rgb(255, 203, 107)"}},{types:["tag","deleted"],style:{color:"rgb(255, 85, 114)"}},{types:["operator"],style:{color:"rgb(137, 221, 255)"}},{types:["boolean"],style:{color:"rgb(255, 88, 116)"}},{types:["keyword"],style:{fontStyle:"italic"}},{types:["doctype"],style:{color:"rgb(199, 146, 234)",fontStyle:"italic"}},{types:["namespace"],style:{color:"rgb(178, 204, 214)"}},{types:["url"],style:{color:"rgb(221, 221, 221)"}}]},ae=n(5350),re=function(){var e=(0,i.LU)().prism,t=(0,ae.Z)().isDarkTheme,n=e.theme||ne,a=e.darkTheme||n;return t?a:n},oe="codeBlockContainer_K1bP",le="codeBlockContent_hGly",ce="codeBlockTitle_eoMF",ie="codeBlock_23N8",se="copyButton_Ue-o",ue="codeBlockLines_39YC",de=/{([\d,-]+)}/,me=["js","jsBlock","jsx","python","html"],pe={js:{start:"\\/\\/",end:""},jsBlock:{start:"\\/\\*",end:"\\*\\/"},jsx:{start:"\\{\\s*\\/\\*",end:"\\*\\/\\s*\\}"},python:{start:"#",end:""},html:{start:"\x3c!--",end:"--\x3e"}},he=["highlight-next-line","highlight-start","highlight-end"],fe=function(e){void 0===e&&(e=me);var t=e.map((function(e){var t=pe[e],n=t.start,a=t.end;return"(?:"+n+"\\s*("+he.join("|")+")\\s*"+a+")"})).join("|");return new RegExp("^\\s*(?:"+t+")\\s*$")};function ye(e){var t=e.children,n=e.className,r=e.metastring,o=e.title,l=(0,i.LU)().prism,s=(0,a.useState)(!1),u=s[0],m=s[1],h=(0,a.useState)(!1),f=h[0],y=h[1];(0,a.useEffect)((function(){y(!0)}),[]);var v=(0,i.bc)(r)||o,b=(0,a.useRef)(null),g=[],k=re(),E=Array.isArray(t)?t.join(""):t;if(r&&de.test(r)){var C=r.match(de)[1];g=te()(C).filter((function(e){return e>0}))}var Z=null==n?void 0:n.split(" ").find((function(e){return e.startsWith("language-")})),T=null==Z?void 0:Z.replace(/language-/,"");!T&&l.defaultLanguage&&(T=l.defaultLanguage);var _=E.replace(/\n$/,"");if(0===g.length&&void 0!==T){for(var N,S="",x=function(e){switch(e){case"js":case"javascript":case"ts":case"typescript":return fe(["js","jsBlock"]);case"jsx":case"tsx":return fe(["js","jsBlock","jsx"]);case"html":return fe(["js","jsBlock","html"]);case"python":case"py":return fe(["python"]);default:return fe()}}(T),I=E.replace(/\n$/,"").split("\n"),j=0;j<I.length;){var B=j+1,L=I[j].match(x);if(null!==L){switch(L.slice(1).reduce((function(e,t){return e||t}),void 0)){case"highlight-next-line":S+=B+",";break;case"highlight-start":N=B;break;case"highlight-end":S+=N+"-"+(B-1)+","}I.splice(j,1)}else j+=1}g=te()(S),_=I.join("\n")}var A=function(){!function(e,t){var n=(void 0===t?{}:t).target,a=void 0===n?document.body:n,r=document.createElement("textarea"),o=document.activeElement;r.value=e,r.setAttribute("readonly",""),r.style.contain="strict",r.style.position="absolute",r.style.left="-9999px",r.style.fontSize="12pt";var l=document.getSelection(),c=!1;l.rangeCount>0&&(c=l.getRangeAt(0)),a.append(r),r.select(),r.selectionStart=0,r.selectionEnd=e.length;var i=!1;try{i=document.execCommand("copy")}catch(s){}r.remove(),c&&(l.removeAllRanges(),l.addRange(c)),o&&o.focus()}(_),m(!0),setTimeout((function(){return m(!1)}),2e3)};return a.createElement(X,(0,d.Z)({},Y,{key:String(f),theme:k,code:_,language:T}),(function(e){var t=e.className,r=e.style,o=e.tokens,l=e.getLineProps,i=e.getTokenProps;return a.createElement("div",{className:(0,c.Z)(oe,null==n?void 0:n.replace(/language-[^ ]+/,""))},v&&a.createElement("div",{style:r,className:ce},v),a.createElement("div",{className:(0,c.Z)(le,T)},a.createElement("pre",{tabIndex:0,className:(0,c.Z)(t,ie,"thin-scrollbar"),style:r},a.createElement("code",{className:ue},o.map((function(e,t){1===e.length&&"\n"===e[0].content&&(e[0].content="");var n=l({line:e,key:t});return g.includes(t+1)&&(n.className+=" docusaurus-highlight-code-line"),a.createElement("span",(0,d.Z)({key:t},n),e.map((function(e,t){return a.createElement("span",(0,d.Z)({key:t},i({token:e,key:t})))})),a.createElement("br",null))})))),a.createElement("button",{ref:b,type:"button","aria-label":(0,p.I)({id:"theme.CodeBlock.copyButtonAriaLabel",message:"Copy code to clipboard",description:"The ARIA label for copy code blocks button"}),className:(0,c.Z)(se,"clean-btn"),onClick:A},u?a.createElement(p.Z,{id:"theme.CodeBlock.copied",description:"The copied button label on code blocks"},"Copied"):a.createElement(p.Z,{id:"theme.CodeBlock.copy",description:"The copy button label on code blocks"},"Copy"))))}))}var ve=n(9649),be="details_1VDD";function ge(e){var t=Object.assign({},e);return a.createElement(i.PO,(0,d.Z)({},t,{className:(0,c.Z)("alert alert--info",be,t.className)}))}var ke=["mdxType","originalType"];var Ee={head:function(e){var t=a.Children.map(e.children,(function(e){return function(e){var t,n;if(null!=e&&null!=(t=e.props)&&t.mdxType&&null!=e&&null!=(n=e.props)&&n.originalType){var r=e.props,o=(r.mdxType,r.originalType,(0,h.Z)(r,ke));return a.createElement(e.props.originalType,o)}return e}(e)}));return a.createElement(W.Z,e,t)},code:function(e){var t=e.children;return(0,a.isValidElement)(t)?t:t.includes("\n")?a.createElement(ye,e):a.createElement("code",e)},a:function(e){return a.createElement(f.Z,e)},pre:function(e){var t,n=e.children;return(0,a.isValidElement)(n)&&(0,a.isValidElement)(null==n||null==(t=n.props)?void 0:t.children)?n.props.children:a.createElement(ye,(0,a.isValidElement)(n)?null==n?void 0:n.props:Object.assign({},e))},details:function(e){var t=a.Children.toArray(e.children),n=t.find((function(e){var t;return"summary"===(null==e||null==(t=e.props)?void 0:t.mdxType)})),r=a.createElement(a.Fragment,null,t.filter((function(e){return e!==n})));return a.createElement(ge,(0,d.Z)({},e,{summary:n}),r)},h1:(0,ve.Z)("h1"),h2:(0,ve.Z)("h2"),h3:(0,ve.Z)("h3"),h4:(0,ve.Z)("h4"),h5:(0,ve.Z)("h5"),h6:(0,ve.Z)("h6")},Ce=n(4608),Ze="backToTopButton_35hR",Te="backToTopButtonShow_18ls";function _e(){var e=(0,a.useRef)(null);return{smoothScrollTop:function(){var t;e.current=(t=null,function e(){var n=document.documentElement.scrollTop;n>0&&(t=requestAnimationFrame(e),window.scrollTo(0,Math.floor(.85*n)))}(),function(){return t&&cancelAnimationFrame(t)})},cancelScrollToTop:function(){return null==e.current?void 0:e.current()}}}var Ne=function(){var e,t=(0,a.useState)(!1),n=t[0],r=t[1],o=(0,a.useRef)(!1),l=_e(),s=l.smoothScrollTop,u=l.cancelScrollToTop;return(0,i.RF)((function(e,t){var n=e.scrollY,a=null==t?void 0:t.scrollY;if(a)if(o.current)o.current=!1;else{var l=n<a;if(l||u(),n<300)r(!1);else if(l){var c=document.documentElement.scrollHeight;n+window.innerHeight<c&&r(!0)}else r(!1)}})),(0,i.SL)((function(e){e.location.hash&&(o.current=!0,r(!1))})),a.createElement("button",{"aria-label":(0,p.I)({id:"theme.BackToTopButton.buttonAriaLabel",message:"Scroll back to top",description:"The ARIA label for the back to top button"}),className:(0,c.Z)("clean-btn",i.kM.common.backToTopButton,Ze,(e={},e[Te]=n,e)),type:"button",onClick:function(){return s()}})},Se=n(6775),xe={docPage:"docPage_31aa",docMainContainer:"docMainContainer_3ufF",docSidebarContainer:"docSidebarContainer_3Kbt",docMainContainerEnhanced:"docMainContainerEnhanced_3NYZ",docSidebarContainerHidden:"docSidebarContainerHidden_3pA8",collapsedDocSidebar:"collapsedDocSidebar_2JMH",expandSidebarButtonIcon:"expandSidebarButtonIcon_1naQ",docItemWrapperEnhanced:"docItemWrapperEnhanced_2vyJ"};function Ie(e){var t,n,o,s=e.currentDocRoute,u=e.versionMetadata,d=e.children,h=u.pluginId,f=u.version,y=s.sidebar,v=y?u.docsSidebars[y]:void 0,b=(0,a.useState)(!1),g=b[0],k=b[1],E=(0,a.useState)(!1),C=E[0],Z=E[1],T=(0,a.useCallback)((function(){C&&Z(!1),k((function(e){return!e}))}),[C]);return a.createElement(l.Z,{wrapperClassName:i.kM.wrapper.docsPages,pageClassName:i.kM.page.docsDocPage,searchMetadatas:{version:f,tag:(0,i.os)(h,f)}},a.createElement("div",{className:xe.docPage},a.createElement(Ne,null),v&&a.createElement("aside",{className:(0,c.Z)(xe.docSidebarContainer,(t={},t[xe.docSidebarContainerHidden]=g,t)),onTransitionEnd:function(e){e.currentTarget.classList.contains(xe.docSidebarContainer)&&g&&Z(!0)}},a.createElement(z,{key:y,sidebar:v,path:s.path,onCollapse:T,isHidden:C}),C&&a.createElement("div",{className:xe.collapsedDocSidebar,title:(0,p.I)({id:"theme.docs.sidebar.expandButtonTitle",message:"Expand sidebar",description:"The ARIA label and title attribute for expand button of doc sidebar"}),"aria-label":(0,p.I)({id:"theme.docs.sidebar.expandButtonAriaLabel",message:"Expand sidebar",description:"The ARIA label and title attribute for expand button of doc sidebar"}),tabIndex:0,role:"button",onKeyDown:T,onClick:T},a.createElement(m,{className:xe.expandSidebarButtonIcon}))),a.createElement("main",{className:(0,c.Z)(xe.docMainContainer,(n={},n[xe.docMainContainerEnhanced]=g||!v,n))},a.createElement("div",{className:(0,c.Z)("container padding-top--md padding-bottom--lg",xe.docItemWrapper,(o={},o[xe.docItemWrapperEnhanced]=g,o))},a.createElement(r.Zo,{components:Ee},d)))))}var je=function(e){var t=e.route.routes,n=e.versionMetadata,r=e.location,l=t.find((function(e){return(0,Se.LX)(r.pathname,e)}));return l?a.createElement(a.Fragment,null,a.createElement(W.Z,null,a.createElement("html",{className:n.className})),a.createElement(Ie,{currentDocRoute:l,versionMetadata:n},(0,o.Z)(t,{versionMetadata:n}))):a.createElement(Ce.default,null)}},7594:function(e,t){function n(e){let t,n=[];for(let a of e.split(",").map((e=>e.trim())))if(/^-?\d+$/.test(a))n.push(parseInt(a,10));else if(t=a.match(/^(-?\d+)(-|\.\.\.?|\u2025|\u2026|\u22EF)(-?\d+)$/)){let[e,a,r,o]=t;if(a&&o){a=parseInt(a),o=parseInt(o);const e=a<o?1:-1;"-"!==r&&".."!==r&&"\u2025"!==r||(o+=e);for(let t=a;t!==o;t+=e)n.push(t)}}return n}t.default=n,e.exports=n}}]);