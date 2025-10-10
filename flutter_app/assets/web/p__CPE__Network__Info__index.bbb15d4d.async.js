"use strict";(self.webpackChunkant_design_pro=self.webpackChunkant_design_pro||[]).push([[92],{59650:function(Lr,We,P){P.r(We);var An=P(97857),p=P.n(An),Rn=P(15009),g=P.n(Rn),Zn=P(99289),Z=P.n(Zn),Bn=P(5574),k=P.n(Bn),Me=P(59955),Tn=P(19693),N=P(2453),Nn=P(33900),be=P(37804),W=P(71230),l=P(15746),A=P(36039),fe=P(77683),Wn=P(66309),Ln=P(72269),_=P(55054),On=P(78957),y=P(67294),e=P(85893),Hn=function(){var Un=(0,y.useState)("\u7B49\u5F85\u72B6\u6001\u4E2D"),Le=k()(Un,2),Ie=Le[0],ne=Le[1],_n=(0,y.useState)(!1),Oe=k()(_n,2),Hr=Oe[0],te=Oe[1],Gn=(0,y.useState)("\u672A\u77E5\u8FD0\u8425\u5546"),He=k()(Gn,2),$n=He[0],xe=He[1],Kn=(0,y.useState)(!1),Ue=k()(Kn,2),Ur=Ue[0],_r=Ue[1],Qn=(0,y.useState)({networkSpeed:{enabled:!1,interval:5},flowStats:{enabled:!1,interval:5},networkInfo:{enabled:!1,interval:5},tempMonitor:{enabled:!1,interval:5}}),_e=k()(Qn,2),L=_e[0],ee=_e[1],qn=(0,y.useState)({networkSpeed:null,flowStats:null,networkInfo:null,tempMonitor:null}),Ge=k()(qn,2),M=Ge[0],q=Ge[1],Vn=(0,y.useState)({networkSpeed:0,flowStats:0,networkInfo:0,tempMonitor:0}),$e=k()(Vn,2),Gr=$e[0],$r=$e[1],Yn=(0,y.useState)({stat:0,lac:"",ci:"",act:-1}),Ke=k()(Yn,2),Kr=Ke[0],Jn=Ke[1],Xn=(0,y.useState)(null),Qe=k()(Xn,2),H=Qe[0],ze=Qe[1],er=(0,y.useState)(!1),qe=k()(er,2),me=qe[0],Pe=qe[1],nr=(0,y.useState)(500),Ve=k()(nr,2),rr=Ve[0],ar=Ve[1],tr=(0,y.useState)(!1),Ye=k()(tr,2),sr=Ye[0],Ae=Ye[1],ir=(0,y.useState)(500),Je=k()(ir,2),Re=Je[0],Xe=Je[1],lr=(0,y.useState)(null),en=k()(lr,2),U=en[0],or=en[1],dr=(0,y.useState)(!1),nn=k()(dr,2),Qr=nn[0],Se=nn[1],ur=(0,y.useState)(0),rn=k()(ur,2),qr=rn[0],pr=rn[1],cr=(0,y.useState)(null),an=k()(cr,2),tn=an[0],Vr=an[1],fr=(0,y.useState)(!1),sn=k()(fr,2),ye=sn[0],xr=sn[1],mr=(0,y.useState)({ipv6Address:"",netmask:"",gateway:"",dhcpServer:"",primaryDNS:"",secondaryDNS:"",maxRxData:0,maxTxData:0}),ln=k()(mr,2),se=ln[0],hr=ln[1],gr=(0,y.useState)({ipv4Address:"",subnetMask:"",gateway:"",dhcpServer:"",primaryDNS:"",secondaryDNS:"",maxRxData:0,maxTxData:0}),on=k()(gr,2),ie=on[0],vr=on[1],br=(0,y.useState)({capValue:0,description:""}),dn=k()(br,2),Ze=dn[0],Sr=dn[1],yr=function(){var f=Z()(g()().mark(function r(a){var o;return g()().wrap(function(n){for(;;)switch(n.prev=n.next){case 0:if(!a){n.next=5;break}Xe(rr),Ae(!0),n.next=15;break;case 5:return n.prev=5,n.next=8,j.setPDCPDataReport(!1);case 8:o=n.sent,o.success?(Pe(!1),ze(null),N.ZP.success("\u5173\u95ED\u5B9E\u65F6\u7F51\u901F\u6210\u529F")):N.ZP.error("\u5173\u95ED\u5B9E\u65F6\u7F51\u901F\u5931\u8D25"),n.next=15;break;case 12:n.prev=12,n.t0=n.catch(5),N.ZP.error("\u8BBE\u7F6EPDCP\u6570\u636E\u4E0A\u62A5\u5931\u8D25");case 15:case"end":return n.stop()}},r,null,[[5,12]])}));return function(a){return f.apply(this,arguments)}}(),wr=function(){var f=Z()(g()().mark(function r(){var a;return g()().wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.prev=0,s.next=3,j.setPDCPDataReport(!0,Re);case 3:a=s.sent,a.success?(Pe(!0),ar(Re),N.ZP.success("\u5B9E\u65F6\u7F51\u901F\u5F00\u542F\u6210\u529F"),Ae(!1)):N.ZP.error("\u5B9E\u65F6\u7F51\u901F\u5F00\u542F\u5931\u8D25"),s.next=10;break;case 7:s.prev=7,s.t0=s.catch(0),N.ZP.error("\u5B9E\u65F6\u7F51\u901F\u5F00\u542F\u5931\u8D25");case 10:case"end":return s.stop()}},r,null,[[0,7]])}));return function(){return f.apply(this,arguments)}}();(0,y.useEffect)(function(){var f=function(a){if(me&&a.type==="pdcp_data"&&"data"in a){var o=a.data;(o.ulPdcpRate>0||o.dlPdcpRate>0)&&or(o),ze(o)}};return j.subscribe(f),function(){j.unsubscribe(f),me&&j.setPDCPDataReport(!1).then(function(){Pe(!1),ze(null)}).catch(function(r){console.error("\u5173\u95EDPDCP\u6570\u636E\u4E0A\u62A5\u5931\u8D25:",r)})}},[me]);var jr=function(){return(0,e.jsx)(e.Fragment,{children:(0,e.jsx)(Nn.Z,{title:"\u4E3B\u52A8\u5237\u65B0\u65F6\u95F4",open:sr,onOk:wr,onCancel:function(){return Ae(!1)},destroyOnClose:!0,children:(0,e.jsxs)("div",{style:{padding:"20px 0"},children:[(0,e.jsx)("div",{style:{marginBottom:"10px",color:"#666"},children:"\u4E3B\u52A8\u5237\u65B0\u65F6\u95F4\uFF08200-65535ms\uFF09\uFF1A"}),(0,e.jsx)(be.Z,{min:200,max:65535,step:100,value:Re,onChange:function(a){return a&&Xe(a)},addonAfter:"ms",style:{width:"100%"}}),(0,e.jsx)("div",{style:{marginTop:"10px",color:"#666",fontSize:"12px"},children:"\u8BF4\u660E\uFF1A\u95F4\u9694\u8D8A\u5C0F\uFF0C\u6570\u636E\u66F4\u65B0\u8D8A\u9891\u7E41\uFF0C\u4F46\u7CFB\u7EDF\u8D1F\u62C5\u8D8A\u5927"})]})})})},le=function(r,a,o){if(r==="networkInfo"){if(M.networkInfo&&(clearInterval(M.networkInfo),q(function(d){return p()(p()({},d),{},{networkInfo:null})}),Se(!1)),a){var s=function(){var d=Z()(g()().mark(function D(){return g()().wrap(function(u){for(;;)switch(u.prev=u.next){case 0:return u.prev=0,Se(!0),u.next=4,we();case 4:u.next=13;break;case 6:u.prev=6,u.t0=u.catch(0),console.error("\u5237\u65B0\u7F51\u7EDC\u4FE1\u606F\u5931\u8D25:",u.t0),N.ZP.error("\u83B7\u53D6\u7F51\u7EDC\u4FE1\u606F\u5931\u8D25"),ee(function(b){return p()(p()({},b),{},{networkInfo:p()(p()({},b.networkInfo),{},{enabled:!1})})}),M.networkInfo&&(clearInterval(M.networkInfo),q(function(b){return p()(p()({},b),{},{networkInfo:null})})),Se(!1);case 13:case"end":return u.stop()}},D,null,[[0,6]])}));return function(){return d.apply(this,arguments)}}();s();var n=setInterval(s,o*1e3);q(function(d){return p()(p()({},d),{},{networkInfo:n})})}ee(function(d){return p()(p()({},d),{},{networkInfo:{enabled:a,interval:o}})})}else if(r==="flowStats"){if(M.flowStats&&(clearInterval(M.flowStats),q(function(d){return p()(p()({},d),{},{flowStats:null})})),a){var h=function(){var d=Z()(g()().mark(function D(){return g()().wrap(function(u){for(;;)switch(u.prev=u.next){case 0:return u.prev=0,u.next=3,ge();case 3:u.next=11;break;case 5:u.prev=5,u.t0=u.catch(0),console.error("\u5237\u65B0\u6D41\u91CF\u7EDF\u8BA1\u5931\u8D25:",u.t0),N.ZP.error("\u5237\u65B0\u6D41\u91CF\u7EDF\u8BA1\u5931\u8D25"),ee(function(b){return p()(p()({},b),{},{flowStats:p()(p()({},b.flowStats),{},{enabled:!1})})}),M.flowStats&&(clearInterval(M.flowStats),q(function(b){return p()(p()({},b),{},{flowStats:null})}));case 11:case"end":return u.stop()}},D,null,[[0,5]])}));return function(){return d.apply(this,arguments)}}();h();var i=setInterval(h,o*1e3);q(function(d){return p()(p()({},d),{},{flowStats:i})})}ee(function(d){return p()(p()({},d),{},{flowStats:{enabled:a,interval:o}})})}else if(r==="networkSpeed"){if(M.networkSpeed&&(clearInterval(M.networkSpeed),q(function(d){return p()(p()({},d),{},{networkSpeed:null})})),a){var t=function(){var d=Z()(g()().mark(function D(){return g()().wrap(function(u){for(;;)switch(u.prev=u.next){case 0:return u.prev=0,u.next=3,ge();case 3:u.next=11;break;case 5:u.prev=5,u.t0=u.catch(0),console.error("\u5237\u65B0\u7F51\u901F\u6570\u636E\u5931\u8D25:",u.t0),N.ZP.error("\u5237\u65B0\u7F51\u901F\u6570\u636E\u5931\u8D25"),ee(function(b){return p()(p()({},b),{},{networkSpeed:p()(p()({},b.networkSpeed),{},{enabled:!1})})}),M.networkSpeed&&(clearInterval(M.networkSpeed),q(function(b){return p()(p()({},b),{},{networkSpeed:null})}));case 11:case"end":return u.stop()}},D,null,[[0,5]])}));return function(){return d.apply(this,arguments)}}();t();var w=setInterval(t,o*1e3);q(function(d){return p()(p()({},d),{},{networkSpeed:w})})}ee(function(d){return p()(p()({},d),{},{networkSpeed:{enabled:a,interval:o}})})}else if(r==="tempMonitor"){if(M.tempMonitor&&(clearInterval(M.tempMonitor),q(function(d){return p()(p()({},d),{},{tempMonitor:null})})),a){var I=function(){var d=Z()(g()().mark(function D(){return g()().wrap(function(u){for(;;)switch(u.prev=u.next){case 0:return u.prev=0,u.next=3,Wr();case 3:u.next=11;break;case 5:u.prev=5,u.t0=u.catch(0),console.error("\u5237\u65B0\u6E29\u5EA6\u6570\u636E\u5931\u8D25:",u.t0),N.ZP.error("\u5237\u65B0\u6E29\u5EA6\u6570\u636E\u5931\u8D25"),ee(function(b){return p()(p()({},b),{},{tempMonitor:p()(p()({},b.tempMonitor),{},{enabled:!1})})}),M.tempMonitor&&(clearInterval(M.tempMonitor),q(function(b){return p()(p()({},b),{},{tempMonitor:null})}));case 11:case"end":return u.stop()}},D,null,[[0,5]])}));return function(){return d.apply(this,arguments)}}();I();var z=setInterval(I,o*1e3);q(function(d){return p()(p()({},d),{},{tempMonitor:z})})}ee(function(d){return p()(p()({},d),{},{tempMonitor:{enabled:a,interval:o}})})}},un={1:"2100 MHz (FDD)",2:"1900 MHz (FDD)",3:"1800 MHz (FDD)",5:"850 MHz (FDD)",7:"2600 MHz (FDD)",8:"900 MHz (FDD)",20:"800 MHz (FDD)",28:"700 MHz (FDD)",38:"2600 MHz (TDD)",40:"2300 MHz (TDD)",41:"2500 MHz (TDD)",77:"3700 MHz (TDD)",78:"3500 MHz (TDD)",79:"4700 MHz (TDD)"},pn={1:"2100 MHz (FDD)",2:"1900 MHz (FDD)",3:"1800 MHz (FDD)",5:"850 MHz (FDD)",7:"2600 MHz (FDD)",8:"900 MHz (FDD)",20:"800 MHz (FDD)",38:"2600 MHz (TDD)",40:"2300 MHz (TDD)",41:"2500 MHz (TDD)"},we=function(){var f=Z()(g()().mark(function r(){var a,o,s,n,h,i,t,w,I,z,d,D,v,u,b,O,T;return g()().wrap(function(c){for(;;)switch(c.prev=c.next){case 0:return c.prev=0,te(!0),c.next=4,j.sendCommand("AT^MONSC");case 4:return a=c.sent,o={},a.success&&a.data&&(s=a.data,s.includes("^MONSC:")?(h=s.replace(/^\^MONSC:\s*/,""),n=h.split(",")):n=s.split(","),n&&n.length>=9&&(o={mcc:n[1],mnc:n[2],channel:n[3],cid:parseInt(n[5],16).toString(),pci:parseInt(n[6],16),lac:parseInt(n[7],16).toString(),rscp:parseInt(n[8],10),signalPercent:ae(parseInt(n[8],10)),ecio:parseFloat(n[9])})),c.next=9,j.sendCommand("AT^HFREQINFO?");case 9:if(i=c.sent,t=[],i.success&&i.data&&(w=i.data.split(`
`),w.forEach(function(C){if(C.startsWith("^HFREQINFO:")){var S=C.replace(/^\^HFREQINFO:\s*/,"").split(",");if(S.length>=9)for(var $=S[1],x=2,V=$==="7"?3:4;x+6<=S.length&&t.length<V;){var R=parseInt(S[x]),K=$==="7"?"n".concat(R):"B".concat(R);t.push({band:R.toString(),bandShortName:K,bandDesc:$==="7"?un[R.toString()]||"\u672A\u77E5\u9891\u6BB5":pn[R.toString()]||"\u672A\u77E5\u9891\u6BB5",dlFcn:S[x+1].trim(),dlFreq:(parseInt(S[x+2])*($==="7"?.001:.1)).toFixed(2),dlBandwidth:parseInt(S[x+3])/1e3,ulFcn:S[x+4].trim(),ulFreq:(parseInt(S[x+5])*($==="7"?.001:.1)).toFixed(2),ulBandwidth:parseInt(S[x+6])/1e3,sysMode:$==="7"?"NR":"LTE"}),x+=7}}})),I=parseFloat(t.reduce(function(C,S){return C+S.dlBandwidth},0).toFixed(2)),z=parseFloat(t.reduce(function(C,S){return C+S.ulBandwidth},0).toFixed(2)),d="",!(t.length>0)){c.next=35;break}if(!(t.some(function(C){return C.sysMode==="NR"})&&t.some(function(C){return C.sysMode==="LTE"}))){c.next=20;break}d="EN-DC (LTE+NR)",c.next=33;break;case 20:if(!t.some(function(C){return C.sysMode==="NR"})){c.next=24;break}d=t.length>1?"NR-CA":"NR",c.next=33;break;case 24:if(!t.some(function(C){return C.sysMode==="LTE"})){c.next=28;break}d=t.length>1?"LTE-CA":"LTE",c.next=33;break;case 28:return c.next=30,j.sendCommand("AT^HCSQ?");case 30:v=c.sent,u=v==null||(D=v.data)===null||D===void 0||(D=D.split(",")[0])===null||D===void 0?void 0:D.replace(/"/g,""),u==="NR"?d="NR":u==="LTE"?d="LTE":u==="WCDMA"?d="WCDMA":d="\u672A\u77E5";case 33:c.next=40;break;case 35:return c.next=37,j.sendCommand("AT^HCSQ?");case 37:O=c.sent,T=O==null||(b=O.data)===null||b===void 0||(b=b.split(",")[0])===null||b===void 0?void 0:b.replace(/"/g,""),T==="NR"?d="NR":T==="LTE"?d="LTE":T==="WCDMA"?d="WCDMA":d="\u672A\u77E5";case 40:re(function(C){return p()(p()(p()({},C),o),{},{carrierInfo:t,carrierCount:t.length,dlBandwidth:I,ulBandwidth:z,networkMode:d,sysMode:d})}),c.next=46;break;case 43:c.prev=43,c.t0=c.catch(0),N.ZP.error("\u83B7\u53D6\u7F51\u7EDC\u4FE1\u606F\u5931\u8D25");case 46:return c.prev=46,te(!1),c.finish(46);case 49:case"end":return c.stop()}},r,null,[[0,43,46,49]])}));return function(){return f.apply(this,arguments)}}(),Dr=(0,y.useState)({rscp:0,signalPercent:"",ecio:0,sinr:0,mcc:"",mnc:"",lac:"",cid:"",channel:"",band:"",dlBandwidth:0,ulBandwidth:0,pci:0,carrierInfo:[],carrierCount:0,networkMode:"",sysMode:"\u672A\u77E5"}),cn=k()(Dr,2),m=cn[0],re=cn[1],Fr=(0,y.useState)({sub3GPA:0,sub6GPA:0,mimoPa:0,tcxo:0,peri1:0,peri2:0,ap1:0,ap2:0,modem1:0,modem2:0,bbp1:0,bbp2:0}),fn=k()(Fr,2),B=fn[0],xn=fn[1],j=Me.S.getInstance(),kr=(0,y.useState)(""),mn=k()(kr,2),Er=mn[0],Cr=mn[1],Mr=(0,y.useState)(0),hn=k()(Mr,2),Be=hn[0],Ir=hn[1],zr=(0,y.useState)(0),gn=k()(zr,2),Te=gn[0],Pr=gn[1],vn=function(){var f=Z()(g()().mark(function r(){var a,o,s,n,h;return g()().wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.prev=0,t.next=3,j.sendCommand("AT^DSAMBR=1");case 3:if(a=t.sent,!(!a.success||!a.data)){t.next=8;break}return t.next=7,j.sendCommand("AT^DSAMBR=8");case 7:a=t.sent;case 8:a.success&&a.data&&(o=a.data.split(","),o.length>=4&&(s=o[3].trim(),Cr(s.substring(1,s.length-1)),n=parseInt(o[1])/1e3,h=parseInt(o[2])/1e3,Ir(n),Pr(h))),t.next=14;break;case 11:t.prev=11,t.t0=t.catch(0),N.ZP.error("\u83B7\u53D6 AMBR \u4FE1\u606F\u5931\u8D25");case 14:case"end":return t.stop()}},r,null,[[0,11]])}));return function(){return f.apply(this,arguments)}}(),Ar=(0,y.useState)("\u672A\u77E5"),bn=k()(Ar,2),Sn=bn[0],Y=bn[1],yn=function(){var f=Z()(g()().mark(function r(){var a,o,s,n;return g()().wrap(function(i){for(;;)switch(i.prev=i.next){case 0:return i.prev=0,i.next=3,j.sendCommand("AT+CGEQOSRDP=8");case 3:if(a=i.sent,!(!a.success||!a.data)){i.next=8;break}return i.next=7,j.sendCommand("AT+CGEQOSRDP=1");case 7:a=i.sent;case 8:if(!(a.success&&a.data)){i.next=38;break}if(o=a.data,s=o.match(/\+CGEQOSRDP:\s*\d+,(\d+)/),!(s&&s[1])){i.next=37;break}n=s[1],i.t0=n,i.next=i.t0==="1"?16:i.t0==="2"?18:i.t0==="3"?20:i.t0==="4"?22:i.t0==="5"?24:i.t0==="6"?26:i.t0==="7"?28:i.t0==="8"?30:i.t0==="9"?32:34;break;case 16:return Y("\u7B49\u7EA71\uFF1AGBR\u4E1A\u52A1,\u5EF6\u8FDF100ms,\u4E22\u5305\u738710^-2,\u9AD8\u4F18\u5148\u7EA7\u8BED\u97F3\u901A\u8BDD"),i.abrupt("break",35);case 18:return Y("\u7B49\u7EA72\uFF1AGBR\u4E1A\u52A1,\u5EF6\u8FDF150ms,\u4E22\u5305\u738710^-3,\u6807\u51C6\u8BED\u97F3\u901A\u8BDD"),i.abrupt("break",35);case 20:return Y("\u7B49\u7EA73\uFF1AGBR\u4E1A\u52A1,\u5EF6\u8FDF50ms,\u4E22\u5305\u738710^-3,\u5B9E\u65F6\u6E38\u620F"),i.abrupt("break",35);case 22:return Y("\u7B49\u7EA74\uFF1AGBR\u4E1A\u52A1,\u5EF6\u8FDF300ms,\u4E22\u5305\u738710^-6,\u975E\u4F1A\u8BDD\u89C6\u9891"),i.abrupt("break",35);case 24:return Y("\u7B49\u7EA75\uFF1A\u975EGBR\u4E1A\u52A1,\u5EF6\u8FDF100ms,\u4E22\u5305\u738710^-6,IMS\u4FE1\u4EE4"),i.abrupt("break",35);case 26:return Y("\u7B49\u7EA76\uFF1A\u975EGBR\u4E1A\u52A1,\u5EF6\u8FDF300ms,\u4E22\u5305\u738710^-6,\u89C6\u9891\u6D41\u5A92\u4F53"),i.abrupt("break",35);case 28:return Y("\u7B49\u7EA77\uFF1A\u975EGBR\u4E1A\u52A1,\u5EF6\u8FDF100ms,\u4E22\u5305\u738710^-3,\u8BED\u97F3\u3001\u89C6\u9891\u3001\u4E92\u52A8\u6E38\u620F"),i.abrupt("break",35);case 30:return Y("\u7B49\u7EA78\uFF1A\u975EGBR\u4E1A\u52A1,\u5EF6\u8FDF300ms,\u4E22\u5305\u738710^-6,\u89C6\u9891\u6D41\u5A92\u4F53\u3001TCP\u5E94\u7528"),i.abrupt("break",35);case 32:return Y("\u7B49\u7EA79\uFF1A\u975EGBR\u4E1A\u52A1,\u5EF6\u8FDF300ms,\u4E22\u5305\u738710^-6,\u6807\u51C6\u6570\u636E\u4F20\u8F93"),i.abrupt("break",35);case 34:Y("QCI ".concat(n,"\uFF1A\u672A\u77E5\u670D\u52A1\u7B49\u7EA7"));case 35:i.next=38;break;case 37:Y("\u672A\u80FD\u83B7\u53D6\u670D\u52A1\u7B49\u7EA7\u4FE1\u606F");case 38:i.next=43;break;case 40:i.prev=40,i.t1=i.catch(0),N.ZP.error("\u83B7\u53D6\u670D\u52A1\u7B49\u7EA7\u4FE1\u606F\u5931\u8D25");case 43:case"end":return i.stop()}},r,null,[[0,40]])}));return function(){return f.apply(this,arguments)}}(),Rr=function(){var f=Z()(g()().mark(function r(){var a,o,s,n,h,i,t,w,I,z,d,D,v,u,b,O,T;return g()().wrap(function(c){for(;;)switch(c.prev=c.next){case 0:return c.prev=0,c.next=3,j.sendCommand("AT^DHCPV6?");case 3:return a=c.sent,a.success&&a.data&&(o=a.data.replace(/^\^DHCPV6:\s*/,""),s=o.split(","),s.length>=8&&hr({ipv6Address:s[0].trim(),netmask:s[1].trim(),gateway:s[2].trim(),dhcpServer:s[3].trim(),primaryDNS:s[4].trim(),secondaryDNS:s[5].trim(),maxRxData:parseInt(s[6].trim()),maxTxData:parseInt(s[7].trim())})),c.next=7,j.sendCommand("AT^DHCP?");case 7:return n=c.sent,n.success&&n.data&&(h=n.data.replace(/^\^DHCP:\s*/,""),i=h.split(","),i.length>=8&&(t=i[0].trim(),w=i[1].trim(),I=i[2].trim(),z=i[3].trim(),d=i[4].trim(),D=i[5].trim(),v=function(S){for(var $=[],x=0;x<S.length;x+=2)$.push(parseInt(S.substr(x,2),16));return $.reverse().join(".")},vr({ipv4Address:v(t),subnetMask:v(w),gateway:v(I),dhcpServer:v(z),primaryDNS:v(d),secondaryDNS:v(D),maxRxData:parseInt(i[6].trim()),maxTxData:parseInt(i[7].trim())}))),c.next=11,j.sendCommand("AT^IPV6CAP?");case 11:if(u=c.sent,!(u.success&&u.data)){c.next=30;break}b=u.data.replace(/^\^IPV6CAP:\s*/,""),O=parseInt(b.trim()),T="",c.t0=O,c.next=c.t0===1?19:c.t0===2?21:c.t0===7?23:c.t0===11?25:27;break;case 19:return T="\u4EC5\u652F\u6301IPv4\u534F\u8BAE",c.abrupt("break",29);case 21:return T="\u4EC5\u652F\u6301IPv6\u534F\u8BAE",c.abrupt("break",29);case 23:return T="\u652F\u6301IPv4\u3001IPv6\u548C\u53CC\u6808\u6A21\u5F0F\uFF08\u4F7F\u7528\u76F8\u540CAPN\uFF09",c.abrupt("break",29);case 25:return T="\u652F\u6301IPv4\u3001IPv6\u548C\u53CC\u6808\u6A21\u5F0F\uFF08\u4F7F\u7528\u4E0D\u540CAPN\uFF09",c.abrupt("break",29);case 27:return T="\u672A\u77E5\u80FD\u529B\u503C (0x".concat(O.toString(16).toUpperCase(),")"),c.abrupt("break",29);case 29:Sr({capValue:O,description:T});case 30:c.next=35;break;case 32:c.prev=32,c.t1=c.catch(0),console.error("\u83B7\u53D6DHCP\u4FE1\u606F\u5931\u8D25:",c.t1);case 35:case"end":return c.stop()}},r,null,[[0,32]])}));return function(){return f.apply(this,arguments)}}(),Zr=(0,y.useState)({lastDsTime:0,lastTxFlow:0,lastRxFlow:0,totalDsTime:0,totalTxFlow:0,totalRxFlow:0}),wn=k()(Zr,2),oe=wn[0],Br=wn[1],Tr=(0,y.useState)({upSpeed:0,downSpeed:0,lastUpdateTime:0,lastTxFlow:0,lastRxFlow:0}),jn=k()(Tr,2),he=jn[0],Dn=jn[1],de=function(r){return parseInt(r,16)},je=function(r){return r<1024?"".concat(r," B"):r<1024*1024?"".concat((r/1024).toFixed(2)," KB"):r<1024*1024*1024?"".concat((r/(1024*1024)).toFixed(2)," MB"):"".concat((r/(1024*1024*1024)).toFixed(2)," GB")},De=function(r){var a=r*8;return a>=1e9?"".concat((a/1e9).toFixed(2)," Gbps"):a>=1e6?"".concat((a/1e6).toFixed(2)," Mbps"):a>=1e3?"".concat((a/1e3).toFixed(2)," Kbps"):"".concat(Math.round(a)," bps")},Fn=function(r){if(ye){var a=Math.floor(r/86400),o=Math.floor(r%86400/3600),s=Math.floor(r%3600/60),n=r%60;return"".concat(a,"\u5929").concat(o,"\u65F6").concat(s,"\u5206").concat(n,"\u79D2")}else{var h=Math.floor(r/3600),i=Math.floor(r%3600/60),t=r%60;return"".concat(h,"\u65F6").concat(i,"\u5206").concat(t,"\u79D2")}},ge=function(){var f=Z()(g()().mark(function r(){var a,o,s,n,h,i,t,w,I,z,d;return g()().wrap(function(v){for(;;)switch(v.prev=v.next){case 0:return v.prev=0,v.next=3,j.sendCommand("AT^DSFLOWQRY");case 3:a=v.sent,a.success&&a.data&&(o=a.data.replace(/^\^DSFLOWQRY:\s*/,""),s=o.split(","),s.length>=6&&(n=Date.now(),h=de(s[4]),i=de(s[5]),he.lastUpdateTime>0?(t=(n-he.lastUpdateTime)/1e3,t>0&&(w=h-he.lastTxFlow,I=i-he.lastRxFlow,z=w/t,d=I/t,Dn({upSpeed:z,downSpeed:d,lastUpdateTime:n,lastTxFlow:h,lastRxFlow:i}))):Dn(p()(p()({},he),{},{lastUpdateTime:n,lastTxFlow:h,lastRxFlow:i})),Br({lastDsTime:de(s[0]),lastTxFlow:de(s[1]),lastRxFlow:de(s[2]),totalDsTime:de(s[3]),totalTxFlow:h,totalRxFlow:i}))),v.next=10;break;case 7:v.prev=7,v.t0=v.catch(0),N.ZP.error("\u83B7\u53D6\u6D41\u91CF\u7EDF\u8BA1\u4FE1\u606F\u5931\u8D25");case 10:case"end":return v.stop()}},r,null,[[0,7]])}));return function(){return f.apply(this,arguments)}}(),Nr=function(){var f=Z()(g()().mark(function r(){var a;return g()().wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.prev=0,s.next=3,j.sendCommand("AT^DSFLOWCLR");case 3:a=s.sent,a.success?(N.ZP.success("\u6D41\u91CF\u7EDF\u8BA1\u5DF2\u6E05\u96F6"),ge()):N.ZP.error("\u6D41\u91CF\u7EDF\u8BA1\u6E05\u96F6\u5931\u8D25"),s.next=10;break;case 7:s.prev=7,s.t0=s.catch(0),N.ZP.error("\u6D41\u91CF\u7EDF\u8BA1\u6E05\u96F6\u5931\u8D25");case 10:case"end":return s.stop()}},r,null,[[0,7]])}));return function(){return f.apply(this,arguments)}}(),kn=function(){var f=Z()(g()().mark(function r(){var a,o,s,n,h,i,t,w,I,z,d,D,v,u,b,O,T,J,c,C,S;return g()().wrap(function(x){for(;;)switch(x.prev=x.next){case 0:return x.prev=0,te(!0),x.next=4,j.sendCommand("AT^HCSQ?");case 4:return a=x.sent,a.success&&a.data&&(o=a.data.split(`
`),s=null,n=null,o.forEach(function(V){var R=V.replace(/^\^HCSQ:\s*/,""),K=R.split(","),G=K[0].replace(/"/g,"");G==="LTE"?s=K:G==="NR"&&(n=K)}),n?(h=parseInt(n[1]),!isNaN(h)&&h!==255&&(i=h===0?-140:h>=97?-44:-140+h,t=ae(i),w=n.length>2?parseInt(n[2]):255,I=0,w!==255&&!isNaN(w)&&(I=w===0?-20:w>=251?30:-20+w*.2,I=Math.min(30,Math.max(-20,I))),re(function(V){return p()(p()({},V),{},{rscp:i,signalPercent:t,sinr:Math.round(I),sysMode:"NR"})}))):s&&(z=parseInt(s[1]),!isNaN(z)&&z!==255&&(d=z===0?-140:z>=97?-44:-140+z,D=ae(d),v=s.length>3?parseInt(s[3]):255,u=0,v!==255&&!isNaN(v)&&(u=v===0?-20:v>=251?30:-20+v*.2,u=Math.min(30,Math.max(-20,u))),b=s.length>4?parseInt(s[4]):255,O=b!==255&&!isNaN(b)?b===0?-19.5:b>=34?-3:-19.5+b*.5:0,re(function(V){return p()(p()({},V),{},{rscp:d,signalPercent:D,sinr:Math.round(u),ecio:Math.round(O),sysMode:"LTE"})})))),x.next=8,j.sendCommand("AT^EONS=2");case 8:if(T=x.sent,!(T.success&&T.data)){x.next=23;break}c=(J=T.data.split(",")[1])===null||J===void 0?void 0:J.trim(),x.t0=c,x.next=x.t0==="46000"||x.t0==="46002"||x.t0==="46004"||x.t0==="46007"||x.t0==="46008"||x.t0==="46020"?14:x.t0==="46001"||x.t0==="46006"||x.t0==="46009"?16:x.t0==="46003"||x.t0==="46005"||x.t0==="46011"?18:x.t0==="46015"?20:22;break;case 14:return xe("\u4E2D\u56FD\u79FB\u52A8"),x.abrupt("break",23);case 16:return xe("\u4E2D\u56FD\u8054\u901A"),x.abrupt("break",23);case 18:return xe("\u4E2D\u56FD\u7535\u4FE1"),x.abrupt("break",23);case 20:return xe("\u4E2D\u56FD\u5E7F\u7535"),x.abrupt("break",23);case 22:xe("\u672A\u77E5\u8FD0\u8425\u5546");case 23:return x.next=25,vn();case 25:return x.next=27,yn();case 27:return x.next=29,Rr();case 29:return x.next=31,ge();case 31:return x.next=33,j.sendCommand("AT^CHIPTEMP?");case 33:C=x.sent,C.success&&C.data&&(S=C.data.split(":")[1].trim().split(","),xn({sub3GPA:parseFloat((parseInt(S[0])/10).toFixed(1)),sub6GPA:parseFloat((parseInt(S[1])/10).toFixed(1)),mimoPa:parseFloat((parseInt(S[2])/10).toFixed(1)),tcxo:parseFloat((parseInt(S[3])/10).toFixed(1)),peri1:parseFloat((parseInt(S[4])/10).toFixed(1)),peri2:parseFloat((parseInt(S[5])/10).toFixed(1)),ap1:parseFloat((parseInt(S[6])/10).toFixed(1)),ap2:parseFloat((parseInt(S[7])/10).toFixed(1)),modem1:parseFloat((parseInt(S[8])/10).toFixed(1)),modem2:parseFloat((parseInt(S[9])/10).toFixed(1)),bbp1:parseFloat((parseInt(S[10])/10).toFixed(1)),bbp2:parseFloat((parseInt(S[11])/10).toFixed(1))})),x.next=40;break;case 37:x.prev=37,x.t1=x.catch(0),N.ZP.error("\u83B7\u53D6\u7F51\u7EDC\u72B6\u6001\u5931\u8D25");case 40:return x.prev=40,te(!1),x.finish(40);case 43:case"end":return x.stop()}},r,null,[[0,37,40,43]])}));return function(){return f.apply(this,arguments)}}(),En=function(){var f=Z()(g()().mark(function r(){var a,o;return g()().wrap(function(n){for(;;)switch(n.prev=n.next){case 0:return n.prev=0,n.next=3,j.getPSRegStatus();case 3:if(a=n.sent,!(a.success&&a.data)){n.next=23;break}o=JSON.parse(a.data),Jn(o),n.t0=o.stat,n.next=n.t0===0?10:n.t0===1?12:n.t0===2?14:n.t0===3?16:n.t0===4?18:n.t0===5?20:22;break;case 10:return ne("\u672A\u641C\u7D22\u7F51\u7EDC"),n.abrupt("break",23);case 12:return ne("\u5DF2\u6CE8\u518C\uFF0C\u672C\u5730\u7F51\u7EDC"),n.abrupt("break",23);case 14:return ne("\u6B63\u5728\u641C\u7D22\u7F51\u7EDC..."),n.abrupt("break",23);case 16:return ne("\u6CE8\u518C\u88AB\u62D2\u7EDD"),n.abrupt("break",23);case 18:return ne("\u672A\u77E5\u72B6\u6001"),n.abrupt("break",23);case 20:return ne("\u5DF2\u6CE8\u518C\uFF0C\u6F2B\u6E38\u7F51\u7EDC"),n.abrupt("break",23);case 22:ne("\u672A\u77E5\u72B6\u6001");case 23:n.next=27;break;case 25:n.prev=25,n.t1=n.catch(0);case 27:case"end":return n.stop()}},r,null,[[0,25]])}));return function(){return f.apply(this,arguments)}}(),Yr=function(){var f=Z()(g()().mark(function r(){var a,o,s,n,h,i,t,w,I,z,d,D,v,u,b,O,T,J,c,C,S,$,x,V,R,K,G,X,ue,Cn,Mn,In,zn,Q,pe,Fe,ke,ce,Ee,Ce;return g()().wrap(function(F){for(;;)switch(F.prev=F.next){case 0:return F.prev=0,F.next=3,j.sendCommand("AT^HCSQ?");case 3:return a=F.sent,a.success&&a.data&&(o=a.data.split(`
`),s=null,n=null,o.forEach(function(E){var ve=E.replace(/^\^HCSQ:\s*/,""),Ne=ve.split(","),Pn=Ne[0].replace(/"/g,"");Pn==="LTE"?s=Ne:Pn==="NR"&&(n=Ne)}),n?(h=parseInt(n[1]),!isNaN(h)&&h!==255&&(i=h===0?-140:h>=97?-44:-140+h,t=n.length>2?parseInt(n[2]):255,w=0,t!==255&&!isNaN(t)&&(w=t===0?-20:t>=251?30:-20+t*.2,w=Math.min(30,Math.max(-20,w))),I=n.length>3?parseInt(n[3]):255,z=I!==255&&!isNaN(I)?I===0?-19.5:I>=34?-3:-19.5+I*.5:0,re(function(E){return p()(p()({},E),{},{rscp:i,signalPercent:ae(i),sinr:Math.round(w),sysMode:"NR",networkMode:s?"EN-DC (LTE+NR)":"NR"})}))):s&&(d=parseInt(s[1]),!isNaN(d)&&d!==255&&(D=d===0?-140:d>=97?-44:-140+d,v=ae(D),u=s.length>3?parseInt(s[3]):255,b=0,u!==255&&!isNaN(u)&&(b=u===0?-20:u>=251?30:-20+u*.2,b=Math.min(30,Math.max(-20,b))),O=s.length>4?parseInt(s[4]):255,T=O!==255&&!isNaN(O)?O===0?-19.5:O>=34?-3:-19.5+O*.5:0,re(function(E){return p()(p()({},E),{},{rscp:D,signalPercent:v,sinr:Math.round(b),ecio:Math.round(T),sysMode:"LTE",networkMode:"LTE"})})))),F.next=7,j.sendCommand("AT^MONSC");case 7:if(J=F.sent,!(J.success&&J.data)){F.next=54;break}return c=J.data,c.includes("^MONSC:")?(S=c.replace(/^\^MONSC:\s*/,""),C=S.split(",")):C=c.split(","),$=parseInt(C[8],10),x=ae($),F.next=15,j.sendCommand("AT^HFREQINFO?");case 15:if(V=F.sent,R=[],K="",!(V.success&&V.data)){F.next=54;break}if(G=V.data.replace(/^\^HFREQINFO:\s*/,"").split(","),R=[],!(G.length>=9)){F.next=54;break}for(K=G[1],X=2;X+6<=G.length&&R.length<3;)ue=parseInt(G[X]),Cn=K==="7"?"n".concat(ue):"B".concat(ue),Mn=K==="7"?un[ue.toString()]||"\u672A\u77E5\u9891\u6BB5":pn[ue.toString()]||"\u672A\u77E5\u9891\u6BB5",R.push({band:ue.toString(),bandShortName:Cn,bandDesc:Mn,dlFcn:G[X+1].trim(),dlFreq:(parseInt(G[X+2])*(K==="7"?.001:.1)).toFixed(2),dlBandwidth:parseInt(G[X+3])/1e3,ulFcn:G[X+4].trim(),ulFreq:(parseInt(G[X+5])*(K==="7"?.001:.1)).toFixed(2),ulBandwidth:parseInt(G[X+6])/1e3,sysMode:K==="7"?"NR":"LTE"}),X+=7;if(In=parseFloat(R.reduce(function(E,ve){return E+ve.dlBandwidth},0).toFixed(2)),zn=parseFloat(R.reduce(function(E,ve){return E+ve.ulBandwidth},0).toFixed(2)),Q="",!(R.length>0)){F.next=48;break}if(!(R.some(function(E){return E.sysMode==="NR"})&&R.some(function(E){return E.sysMode==="LTE"}))){F.next=33;break}Q="EN-DC (LTE+NR)",F.next=46;break;case 33:if(!R.some(function(E){return E.sysMode==="NR"})){F.next=37;break}Q=R.length>1?"NR-CA":"NR",F.next=46;break;case 37:if(!R.some(function(E){return E.sysMode==="LTE"})){F.next=41;break}Q=R.length>1?"LTE-CA":"LTE",F.next=46;break;case 41:return F.next=43,j.sendCommand("AT^HCSQ?");case 43:Fe=F.sent,ke=Fe==null||(pe=Fe.data)===null||pe===void 0||(pe=pe.split(",")[0])===null||pe===void 0?void 0:pe.replace(/"/g,""),ke==="NR"?Q="NR":ke==="LTE"?Q="LTE":ke==="WCDMA"?Q="WCDMA":Q="\u672A\u77E5";case 46:F.next=53;break;case 48:return F.next=50,j.sendCommand("AT^HCSQ?");case 50:Ee=F.sent,Ce=Ee==null||(ce=Ee.data)===null||ce===void 0||(ce=ce.split(",")[0])===null||ce===void 0?void 0:ce.replace(/"/g,""),Ce==="NR"?Q="NR":Ce==="LTE"?Q="LTE":Ce==="WCDMA"?Q="WCDMA":Q="\u672A\u77E5";case 53:re(function(E){return p()(p()({},E),{},{carrierInfo:R,carrierCount:R.length,dlBandwidth:In,ulBandwidth:zn,networkMode:Q,mcc:E.mcc,mnc:E.mnc,lac:E.lac,cid:E.cid,channel:E.channel,pci:E.pci,rscp:E.rscp,signalPercent:E.signalPercent,ecio:E.ecio,sinr:E.sinr})});case 54:F.next=59;break;case 56:F.prev=56,F.t0=F.catch(0),console.error("\u5237\u65B0\u7F51\u7EDC\u4FE1\u606F\u5931\u8D25:",F.t0);case 59:case"end":return F.stop()}},r,null,[[0,56]])}));return function(){return f.apply(this,arguments)}}(),Wr=function(){var f=Z()(g()().mark(function r(){var a,o;return g()().wrap(function(n){for(;;)switch(n.prev=n.next){case 0:return n.prev=0,n.next=3,j.sendCommand("AT^CHIPTEMP?");case 3:a=n.sent,a.success&&a.data&&(o=a.data.split(":")[1].trim().split(","),xn({sub3GPA:parseFloat((parseInt(o[0])/10).toFixed(1)),sub6GPA:parseFloat((parseInt(o[1])/10).toFixed(1)),mimoPa:parseFloat((parseInt(o[2])/10).toFixed(1)),tcxo:parseFloat((parseInt(o[3])/10).toFixed(1)),peri1:parseFloat((parseInt(o[4])/10).toFixed(1)),peri2:parseFloat((parseInt(o[5])/10).toFixed(1)),ap1:parseFloat((parseInt(o[6])/10).toFixed(1)),ap2:parseFloat((parseInt(o[7])/10).toFixed(1)),modem1:parseFloat((parseInt(o[8])/10).toFixed(1)),modem2:parseFloat((parseInt(o[9])/10).toFixed(1)),bbp1:parseFloat((parseInt(o[10])/10).toFixed(1)),bbp2:parseFloat((parseInt(o[11])/10).toFixed(1))})),n.next=11;break;case 7:throw n.prev=7,n.t0=n.catch(0),console.error("\u5237\u65B0\u6E29\u5EA6\u6570\u636E\u5931\u8D25:",n.t0),n.t0;case 11:case"end":return n.stop()}},r,null,[[0,7]])}));return function(){return f.apply(this,arguments)}}();(0,y.useEffect)(function(){var f=function(){var r=Z()(g()().mark(function a(){var o;return g()().wrap(function(n){for(;;)switch(n.prev=n.next){case 0:return n.next=2,j.connect();case 2:if(o=n.sent,!o){n.next=20;break}return n.prev=4,te(!0),n.next=8,En();case 8:return n.next=10,we();case 10:return n.next=12,kn();case 12:n.next=17;break;case 14:n.prev=14,n.t0=n.catch(4),N.ZP.error("\u521D\u59CB\u5316\u7F51\u7EDC\u4FE1\u606F\u5931\u8D25");case 17:return n.prev=17,te(!1),n.finish(17);case 20:case"end":return n.stop()}},a,null,[[4,14,17,20]])}));return function(){return r.apply(this,arguments)}}();return f(),function(){Object.values(M).forEach(function(r){r&&clearInterval(r)}),j.disconnect()}},[]);var Jr=function(r){return r>=31?4:r>=21?3:r>=11?2:r>=1?1:0};(0,y.useEffect)(function(){var f=Me.S.getInstance(),r=function(o){};return f.subscribe(r),function(){f.unsubscribe(r)}},[]),(0,y.useEffect)(function(){var f=Me.S.getInstance(),r=null,a=function(){var n=Z()(g()().mark(function h(i){var t,w;return g()().wrap(function(z){for(;;)switch(z.prev=z.next){case 0:if(!L.networkInfo.enabled){z.next=2;break}return z.abrupt("return");case 2:i.type==="signal_data"&&i.success&&(t=i.data,w={},t.rsrp!==void 0&&(w.rscp=t.rsrp,w.signalPercent=ae(t.rsrp)),t.sinr!==void 0&&(w.sinr=t.sinr),t.rsrq!==void 0&&(w.ecio=t.rsrq),t.rssi!==void 0&&(w.rscp=t.rssi),Object.keys(w).length>0&&re(function(d){return p()(p()({},d),w)}),r&&clearInterval(r),Se(!0),pr(0),setTimeout(Z()(g()().mark(function d(){return g()().wrap(function(v){for(;;)switch(v.prev=v.next){case 0:return v.next=2,we();case 2:case"end":return v.stop()}},d)})),5e3));case 3:case"end":return z.stop()}},h)}));return function(i){return n.apply(this,arguments)}}(),o=function(){var n=Z()(g()().mark(function h(){return g()().wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.prev=0,t.next=3,we();case 3:return t.next=5,kn();case 5:t.next=10;break;case 7:t.prev=7,t.t0=t.catch(0),console.error("\u6570\u636E\u5237\u65B0\u5931\u8D25:",t.t0);case 10:case"end":return t.stop()}},h,null,[[0,7]])}));return function(){return n.apply(this,arguments)}}(),s=function(){var n=Z()(g()().mark(function h(){return g()().wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.prev=0,t.next=3,o();case 3:return t.next=5,vn();case 5:return t.next=7,yn();case 7:return t.next=9,En();case 9:return t.next=11,ge();case 11:t.next=16;break;case 13:t.prev=13,t.t0=t.catch(0),console.error("\u6570\u636E\u5237\u65B0\u5931\u8D25:",t.t0);case 16:case"end":return t.stop()}},h,null,[[0,13]])}));return function(){return n.apply(this,arguments)}}();return f.subscribe(a),function(){f.unsubscribe(a),r&&clearInterval(r),tn&&clearInterval(tn),M.networkSpeed&&clearInterval(M.networkSpeed),M.flowStats&&clearInterval(M.flowStats),M.networkInfo&&clearInterval(M.networkInfo),M.tempMonitor&&clearInterval(M.tempMonitor)}},[]);var ae=function(r){return r>=-80?"100%":r>=-90?"90%":r>=-100?"80%":r>=-110?"50%":"25%"};return(0,e.jsxs)("div",{children:[(0,e.jsxs)(W.Z,{gutter:[16,16],children:[(0,e.jsx)(l.Z,{xs:24,md:24,children:(0,e.jsx)(A.Z,{title:(0,e.jsxs)("div",{style:{display:"flex",alignItems:"center",gap:"8px"},children:[(0,e.jsx)("span",{children:"\u7F51\u7EDC\u4FE1\u606F"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",background:"#f5f5f5",padding:"2px 8px",borderRadius:"4px",fontWeight:"normal"},children:"\u5C55\u793A\u5F53\u524D\u7F51\u7EDC\u7684\u5404\u9879\u5173\u952E\u6307\u6807"})]}),extra:(0,e.jsxs)(fe.ZP,{type:"link",size:"small",style:{padding:"0 8px",height:"28px",display:"flex",alignItems:"center",gap:"4px",background:L.networkInfo.enabled?"#e6f7ff":"transparent",border:"1px solid #91d5ff",borderRadius:"4px"},onClick:function(r){r.target.closest(".ant-input-number")||le("networkInfo",!L.networkInfo.enabled,L.networkInfo.interval)},children:[(0,e.jsx)("span",{children:"\u81EA\u52A8\u5237\u65B0"}),L.networkInfo.enabled&&(0,e.jsx)(be.Z,{min:1,max:60,value:L.networkInfo.interval,onChange:function(r){return le("networkInfo",!0,r||5)},style:{width:45},size:"small",bordered:!1}),L.networkInfo.enabled&&(0,e.jsx)("span",{children:"\u79D2"})]}),className:"inner-card",children:(0,e.jsxs)(W.Z,{gutter:[16,16],children:[(0,e.jsx)(l.Z,{xs:24,lg:16,children:(0,e.jsx)(A.Z,{size:"small",title:(0,e.jsxs)("div",{style:{display:"flex",alignItems:"center",gap:"8px"},children:["\u4FE1\u53F7\u770B\u677F",m.networkMode&&(0,e.jsx)("span",{style:{fontSize:"13px",backgroundColor:m.networkMode.includes("NR")?"#52c41a":m.networkMode.includes("LTE")?"#1890ff":m.networkMode.includes("WCDMA")?"#faad14":m.networkMode.includes("GSM")?"#ff4d4f":"#999",color:"#fff",padding:"1px 6px",borderRadius:"10px",marginLeft:"8px"},children:m.networkMode}),(0,e.jsx)(Wn.Z,{color:Ie.includes("\u672C\u5730")?"success":Ie.includes("\u6F2B\u6E38")?"warning":"error",children:Ie})]}),bordered:!0,style:{background:"var(--ant-bg-elevated)",height:"100%",border:"1px solid var(--ant-border-color-split)",boxShadow:"0 1px 2px 0 rgba(0, 0, 0, 0.03), 0 1px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px 0 rgba(0, 0, 0, 0.02)"},children:(0,e.jsxs)(W.Z,{gutter:[16,16],children:[(0,e.jsx)(l.Z,{xs:6,sm:6,children:(0,e.jsxs)("div",{style:{textAlign:"center"},children:[(0,e.jsx)(Tn.Z,{style:{fontSize:"32px",color:m.signalPercent==="100%"||m.signalPercent==="90%"?"#52c41a":m.signalPercent==="80%"?"#faad14":(m.signalPercent==="50%","#ff4d4f")}}),(0,e.jsx)("div",{style:{marginTop:"8px",fontWeight:"bold",color:m.signalPercent==="100%"||m.signalPercent==="90%"?"#52c41a":m.signalPercent==="80%"?"#faad14":(m.signalPercent==="50%","#ff4d4f")},children:m.signalPercent||"\u672A\u77E5"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"var(--ant-text-color-secondary)"},children:"\u4FE1\u53F7\u8D28\u91CF"})]})}),(0,e.jsx)(l.Z,{xs:6,sm:6,children:(0,e.jsxs)("div",{style:{textAlign:"center"},children:[(0,e.jsx)("div",{style:{fontSize:"24px",fontWeight:"bold",color:m.rscp>=-85?"#52c41a":m.rscp>=-95?"#faad14":"#ff4d4f"},children:m.rscp}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"var(--ant-text-color-secondary)"},children:m.networkMode.includes("NR")||m.networkMode.includes("LTE")?"RSRP (dBm)":m.networkMode.includes("WCDMA")?"RSCP (dBm)":"RSSI (dBm)"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"var(--ant-text-color-secondary)"},children:m.networkMode.includes("NR")||m.networkMode.includes("LTE")?"\u53C2\u8003\u4FE1\u53F7\u63A5\u6536\u529F\u7387":m.networkMode.includes("WCDMA")?"\u63A5\u6536\u4FE1\u53F7\u7801\u529F\u7387":"\u63A5\u6536\u4FE1\u53F7\u5F3A\u5EA6\u6307\u793A"})]})}),(0,e.jsx)(l.Z,{xs:6,sm:6,children:(0,e.jsxs)("div",{style:{textAlign:"center"},children:[(0,e.jsx)("div",{style:{fontSize:"24px",fontWeight:"bold",color:m.sinr>=20?"#52c41a":m.sinr>=10?"#faad14":"#ff4d4f"},children:m.sinr}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"var(--ant-text-color-secondary)"},children:m.networkMode.includes("NR")||m.networkMode.includes("LTE")?"SINR (dB)":m.networkMode.includes("WCDMA")?"Ec/Io (dB)":"SINR (dB)"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"var(--ant-text-color-secondary)"},children:m.networkMode.includes("NR")||m.networkMode.includes("LTE")?"\u4FE1\u566A\u6BD4":m.networkMode.includes("WCDMA")?"\u5BFC\u9891\u4FE1\u53F7\u80FD\u91CF/\u5E72\u6270\u6BD4":"\u4FE1\u566A\u6BD4"})]})}),(0,e.jsx)(l.Z,{xs:6,sm:6,children:(0,e.jsxs)("div",{style:{textAlign:"center"},children:[(0,e.jsx)("div",{style:{fontSize:"24px",fontWeight:"bold",color:m.ecio>=-10?"#52c41a":m.ecio>=-15?"#faad14":"#ff4d4f"},children:m.ecio}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"var(--ant-text-color-secondary)"},children:m.networkMode.includes("NR")||m.networkMode.includes("LTE")?"RSRQ (dB)":m.networkMode.includes("WCDMA")?"ECIO (dB)":"RSSI (dBm)"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"var(--ant-text-color-secondary)"},children:m.networkMode.includes("NR")||m.networkMode.includes("LTE")?"\u53C2\u8003\u4FE1\u53F7\u63A5\u6536\u8D28\u91CF":m.networkMode.includes("WCDMA")?"\u5BFC\u9891\u4FE1\u9053\u63A5\u6536\u8D28\u91CF":"\u63A5\u6536\u4FE1\u53F7\u5F3A\u5EA6\u6307\u793A"})]})})]})})}),(0,e.jsx)(l.Z,{xs:24,lg:8,children:(0,e.jsx)(A.Z,{size:"small",title:"\u7F51\u7EDC\u53C2\u6570",bordered:!1,style:{background:"#f9f9f9",height:"100%"},children:(0,e.jsxs)(W.Z,{gutter:[16,8],children:[(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"PCI:"}),(0,e.jsx)("div",{style:{fontWeight:"bold"},children:m.pci})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u9891\u70B9:"}),(0,e.jsx)("div",{style:{fontWeight:"bold"},children:m.channel})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"MCC-MNC:"}),(0,e.jsxs)("div",{style:{fontWeight:"bold"},children:[m.mcc,"-",m.mnc]})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"LAC:"}),(0,e.jsx)("div",{style:{fontWeight:"bold"},children:m.lac})]}),(0,e.jsxs)(l.Z,{span:24,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u5C0F\u533AID:"}),(0,e.jsx)("div",{style:{fontWeight:"bold"},children:m.cid})]})]})})}),(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsx)(A.Z,{type:"inner",title:(0,e.jsxs)("span",{children:["\u8F7D\u6CE2\u805A\u5408\u4FE1\u606F",m.carrierCount>0?(0,e.jsxs)("span",{style:{marginLeft:"8px",fontSize:"14px",color:"#1890ff"},children:["(",m.carrierCount,"\u8F7D\u6CE2 | \u603B\u5E26\u5BBD: \u4E0B\u884C",m.dlBandwidth,"MHz/\u4E0A\u884C",m.ulBandwidth,"MHz)"]}):(0,e.jsx)("span",{style:{marginLeft:"8px",fontSize:"14px",color:"var(--ant-text-color-secondary)"},children:"\u65E0\u8F7D\u6CE2"})]}),style:{background:"var(--ant-bg-elevated)",border:"1px solid var(--ant-border-color-split)",boxShadow:"0 1px 2px 0 rgba(0, 0, 0, 0.03), 0 1px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px 0 rgba(0, 0, 0, 0.02)"},children:m.carrierInfo.length>0?(0,e.jsx)("div",{children:(0,e.jsx)(W.Z,{gutter:[16,16],children:m.carrierInfo.map(function(f,r){return(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,children:(0,e.jsxs)(A.Z,{size:"small",title:(0,e.jsxs)("span",{style:{color:r===0?"#1890ff":"#666",fontWeight:r===0?"bold":"normal"},children:[r===0?"\u4E3B\u8F7D\u6CE2":"\u8F85\u8F7D\u6CE2 ".concat(r),(0,e.jsxs)("span",{style:{marginLeft:"8px",fontSize:"12px",color:f.sysMode==="NR"?"#52c41a":"#fa8c16"},children:["(",f.sysMode,")"]})]}),style:{borderLeft:r===0?"3px solid #1890ff":f.sysMode==="NR"?"3px solid #52c41a":"3px solid #fa8c16",height:"100%",boxShadow:"0 2px 8px rgba(0,0,0,0.09)"},children:[(0,e.jsxs)("div",{style:{marginBottom:"8px"},children:[(0,e.jsx)("span",{style:{fontWeight:"bold"},children:f.bandShortName}),(0,e.jsxs)("span",{style:{color:"#666",fontSize:"12px",marginLeft:"8px"},children:["(",f.bandDesc,")"]})]}),(0,e.jsxs)(W.Z,{gutter:[8,8],children:[(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u4E0B\u884C\u9891\u70B9:"}),(0,e.jsx)("div",{children:f.dlFcn})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u4E0A\u884C\u9891\u70B9:"}),(0,e.jsx)("div",{children:f.ulFcn})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u4E0B\u884C\u9891\u7387:"}),(0,e.jsxs)("div",{children:[f.dlFreq," MHz"]})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u4E0A\u884C\u9891\u7387:"}),(0,e.jsxs)("div",{children:[f.ulFreq," MHz"]})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u4E0B\u884C\u5E26\u5BBD:"}),(0,e.jsxs)("div",{children:[f.dlBandwidth," MHz"]})]}),(0,e.jsxs)(l.Z,{span:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666"},children:"\u4E0A\u884C\u5E26\u5BBD:"}),(0,e.jsxs)("div",{children:[f.ulBandwidth," MHz"]})]})]})]})},r)})})}):(0,e.jsx)("div",{style:{color:"#666",fontSize:"14px",padding:"16px 0",textAlign:"center"},children:"\u5F53\u524D\u672A\u83B7\u53D6\u5230\u8F7D\u6CE2\u4FE1\u606F\u6216\u672A\u542F\u7528\u8F7D\u6CE2\u805A\u5408"})})})]})})}),(0,e.jsx)(l.Z,{xs:24,md:12,children:(0,e.jsx)(A.Z,{title:(0,e.jsxs)("div",{style:{display:"flex",alignItems:"center",gap:"8px"},children:[(0,e.jsx)("span",{children:"\u7F51\u7EDC\u901F\u7387\u4FE1\u606F"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",background:"#f5f5f5",padding:"2px 8px",borderRadius:"4px",fontWeight:"normal"},children:"\u5C55\u793A\u7F51\u7EDC\u901F\u7387\u76F8\u5173\u4FE1\u606F"})]}),extra:(0,e.jsx)(Ln.Z,{checkedChildren:"\u5B9E\u65F6\u7F51\u901F\u5F00\u542F",unCheckedChildren:"\u5B9E\u65F6\u7F51\u901F\u5173\u95ED",checked:me,onChange:yr}),className:"inner-card",style:{height:"100%"},children:(0,e.jsxs)(W.Z,{gutter:[24,24],children:[(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsxs)(A.Z,{size:"small",title:"\u5B9E\u65F6\u7F51\u901F",bordered:!1,style:{background:"#f9f9f9",position:"relative"},children:[me?null:(0,e.jsx)("div",{style:{position:"absolute",top:0,left:0,right:0,bottom:0,background:"rgba(255, 255, 255, 0.9)",display:"flex",alignItems:"center",justifyContent:"center",zIndex:1},children:(0,e.jsx)("div",{style:{color:"#999",fontSize:"14px"},children:"\u6682\u672A\u5F00\u542F\u5B9E\u65F6\u7F51\u901F\u76D1\u63A7"})}),(0,e.jsxs)(W.Z,{gutter:[16,16],children:[(0,e.jsx)(l.Z,{xs:12,children:(0,e.jsx)(_.Z,{title:"\u4E0A\u884C\u901F\u7387",value:H&&H.ulPdcpRate>0?De(H.ulPdcpRate):U?De(U.ulPdcpRate):"0 bps",valueStyle:{color:((H==null?void 0:H.ulPdcpRate)||(U==null?void 0:U.ulPdcpRate)||0)*8>=1e8?"#52c41a":((H==null?void 0:H.ulPdcpRate)||(U==null?void 0:U.ulPdcpRate)||0)*8>=1e7?"#1890ff":"#faad14",fontSize:"18px"}})}),(0,e.jsx)(l.Z,{xs:12,children:(0,e.jsx)(_.Z,{title:"\u4E0B\u884C\u901F\u7387",value:H&&H.dlPdcpRate>0?De(H.dlPdcpRate):U?De(U.dlPdcpRate):"0 bps",valueStyle:{color:((H==null?void 0:H.dlPdcpRate)||(U==null?void 0:U.dlPdcpRate)||0)*8>=1e8?"#52c41a":((H==null?void 0:H.dlPdcpRate)||(U==null?void 0:U.dlPdcpRate)||0)*8>=1e7?"#1890ff":"#faad14",fontSize:"18px"}})})]})]})}),(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsx)(A.Z,{size:"small",title:"\u5F53\u524D\u7F51\u7EDC",bordered:!1,style:{background:"#f9f9f9"},children:(0,e.jsxs)(W.Z,{gutter:[16,16],children:[(0,e.jsx)(l.Z,{xs:24,sm:12,children:(0,e.jsxs)(W.Z,{gutter:[8,8],children:[(0,e.jsx)(l.Z,{span:12,children:(0,e.jsxs)("div",{style:{background:"#fff",padding:"8px 12px",borderRadius:"4px",height:"100%"},children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u4E0A\u884C\u901F\u7387"}),(0,e.jsxs)("div",{style:{fontSize:"16px",fontWeight:500,color:Te>=50?"#52c41a":Te>=25?"#faad14":"#ff4d4f"},children:[Te," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"Mbps"})]})]})}),(0,e.jsx)(l.Z,{span:12,children:(0,e.jsxs)("div",{style:{background:"#fff",padding:"8px 12px",borderRadius:"4px",height:"100%"},children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u4E0B\u884C\u901F\u7387"}),(0,e.jsxs)("div",{style:{fontSize:"16px",fontWeight:500,color:Be>=100?"#52c41a":Be>=50?"#faad14":"#ff4d4f"},children:[Be," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"Mbps"})]})]})})]})}),(0,e.jsx)(l.Z,{xs:24,sm:12,children:(0,e.jsxs)(W.Z,{gutter:[8,8],children:[(0,e.jsx)(l.Z,{span:12,children:(0,e.jsxs)("div",{style:{background:"#fff",padding:"8px 12px",borderRadius:"4px",height:"100%"},children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u8FD0\u8425\u5546"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500},children:$n})]})}),(0,e.jsx)(l.Z,{span:12,children:(0,e.jsxs)("div",{style:{background:"#fff",padding:"8px 12px",borderRadius:"4px",height:"100%"},children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"APN"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500},children:Er||"\u672A\u77E5"})]})})]})}),(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsxs)("div",{style:{background:"#fff",padding:"8px 12px",borderRadius:"4px"},children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"QCI (\u670D\u52A1\u8D28\u91CF\u7B49\u7EA7)"}),(0,e.jsxs)("div",{style:{fontSize:"14px",color:"#666"},children:[Sn.split("\uFF1A")[0],(0,e.jsx)("span",{style:{marginLeft:"8px",fontSize:"12px",color:"#999"},children:Sn.split("\uFF1A")[1]})]})]})})]})})})]})})}),(0,e.jsx)(l.Z,{xs:24,md:12,children:(0,e.jsx)(A.Z,{title:(0,e.jsxs)("div",{style:{display:"flex",alignItems:"center",gap:"8px"},children:[(0,e.jsx)("span",{children:"\u6D41\u91CF\u7EDF\u8BA1"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",background:"#f5f5f5",padding:"2px 8px",borderRadius:"4px",fontWeight:"normal"},children:"\u5C55\u793A\u7F51\u7EDC\u8FDE\u63A5\u65F6\u95F4\u548C\u6D41\u91CF\u4FE1\u606F"})]}),extra:(0,e.jsxs)(On.Z,{children:[(0,e.jsx)(fe.ZP,{type:ye?"primary":"default",onClick:function(){return xr(!ye)},size:"small",children:ye?"\u663E\u793A\u65F6\u5206\u79D2":"\u663E\u793A\u5929\u6570"}),(0,e.jsxs)(fe.ZP,{type:"link",size:"small",style:{padding:"0 8px",height:"28px",display:"flex",alignItems:"center",gap:"4px",background:L.flowStats.enabled?"#e6f7ff":"transparent",border:"1px solid #91d5ff",borderRadius:"4px"},onClick:function(r){r.target.closest(".ant-input-number")||le("flowStats",!L.flowStats.enabled,L.flowStats.interval)},children:[(0,e.jsx)("span",{children:"\u81EA\u52A8\u5237\u65B0"}),L.flowStats.enabled&&(0,e.jsx)(be.Z,{min:1,max:60,value:L.flowStats.interval,onChange:function(r){return le("flowStats",!0,r||5)},style:{width:45},size:"small",bordered:!1}),L.flowStats.enabled&&(0,e.jsx)("span",{children:"\u79D2"})]})]}),className:"inner-card",style:{height:"100%"},children:(0,e.jsxs)(W.Z,{gutter:[24,24],children:[(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsx)(A.Z,{size:"small",title:"\u6700\u540E\u4E00\u6B21\u8FDE\u63A5",bordered:!1,style:{background:"#f9f9f9"},children:(0,e.jsxs)(W.Z,{gutter:[24,16],children:[(0,e.jsx)(l.Z,{xs:24,sm:8,children:(0,e.jsx)(_.Z,{title:"\u8FDE\u63A5\u65F6\u957F",value:Fn(oe.lastDsTime),valueStyle:{fontSize:"16px"}})}),(0,e.jsx)(l.Z,{xs:24,sm:8,children:(0,e.jsx)(_.Z,{title:"\u4E0A\u4F20\u6D41\u91CF",value:je(oe.lastTxFlow),valueStyle:{fontSize:"16px"}})}),(0,e.jsx)(l.Z,{xs:24,sm:8,children:(0,e.jsx)(_.Z,{title:"\u4E0B\u8F7D\u6D41\u91CF",value:je(oe.lastRxFlow),valueStyle:{fontSize:"16px"}})})]})})}),(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsx)(A.Z,{size:"small",title:"\u7D2F\u8BA1\u7EDF\u8BA1",bordered:!1,style:{background:"#f9f9f9"},children:(0,e.jsxs)(W.Z,{gutter:[24,16],children:[(0,e.jsx)(l.Z,{xs:24,sm:8,children:(0,e.jsx)(_.Z,{title:"\u603B\u8FDE\u63A5\u65F6\u957F",value:Fn(oe.totalDsTime),valueStyle:{fontSize:"16px"}})}),(0,e.jsx)(l.Z,{xs:24,sm:8,children:(0,e.jsx)(_.Z,{title:"\u603B\u4E0A\u4F20\u6D41\u91CF",value:je(oe.totalTxFlow),valueStyle:{fontSize:"16px"}})}),(0,e.jsx)(l.Z,{xs:24,sm:8,children:(0,e.jsx)(_.Z,{title:"\u603B\u4E0B\u8F7D\u6D41\u91CF",value:je(oe.totalRxFlow),valueStyle:{fontSize:"16px"}})})]})})}),(0,e.jsx)(l.Z,{xs:24,style:{marginTop:8,textAlign:"right"},children:(0,e.jsx)(fe.ZP,{danger:!0,onClick:Nr,size:"middle",children:"\u6E05\u96F6"})})]})})}),(0,e.jsx)(l.Z,{xs:24,md:12,children:jr()}),(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsx)(A.Z,{title:(0,e.jsxs)("div",{style:{display:"flex",alignItems:"center",gap:"8px"},children:[(0,e.jsx)("span",{children:"DHCP\u914D\u7F6E\u4FE1\u606F"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",background:"#f5f5f5",padding:"2px 8px",borderRadius:"4px",fontWeight:"normal"},children:"\u5C55\u793AIPv4/IPv6\u7F51\u7EDC\u914D\u7F6E"})]}),className:"inner-card",style:{height:"100%"},children:(0,e.jsxs)(W.Z,{gutter:[16,16],children:[(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsx)(A.Z,{size:"small",title:"IPv6\u80FD\u529B\u914D\u7F6E",bordered:!1,style:{background:"#f9f9f9",marginBottom:"16px"},children:(0,e.jsxs)(W.Z,{gutter:[16,8],children:[(0,e.jsxs)(l.Z,{xs:24,sm:8,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u80FD\u529B\u503C"}),(0,e.jsxs)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:["0x",Ze.capValue?Ze.capValue.toString(16).toUpperCase().padStart(2,"0"):"00"]})]}),(0,e.jsxs)(l.Z,{xs:24,sm:16,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u80FD\u529B\u63CF\u8FF0"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500},children:Ze.description||"\u672A\u83B7\u53D6"})]})]})})}),(0,e.jsx)(l.Z,{xs:24,md:12,children:(0,e.jsx)(A.Z,{size:"small",title:"IPv4 \u7F51\u7EDC\u914D\u7F6E",bordered:!1,style:{background:"#f9f9f9",height:"100%"},children:(0,e.jsxs)(W.Z,{gutter:[16,8],children:[(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"IPv4\u5730\u5740"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:ie.ipv4Address||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u5B50\u7F51\u63A9\u7801"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:ie.subnetMask||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u7F51\u5173"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:ie.gateway||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"DHCP\u670D\u52A1\u5668"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:ie.dhcpServer||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u9996\u9009DNS"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:ie.primaryDNS||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u5907\u7528DNS"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:ie.secondaryDNS||"\u672A\u83B7\u53D6"})]})]})})}),(0,e.jsx)(l.Z,{xs:24,md:12,children:(0,e.jsx)(A.Z,{size:"small",title:"IPv6 \u7F51\u7EDC\u914D\u7F6E",bordered:!1,style:{background:"#f9f9f9",height:"100%"},children:(0,e.jsxs)(W.Z,{gutter:[16,8],children:[(0,e.jsxs)(l.Z,{xs:24,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"IPv6\u5730\u5740"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace",wordBreak:"break-all"},children:se.ipv6Address||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"IPv6\u5B50\u7F51\u63A9\u7801"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:se.netmask||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"IPv6\u7F51\u5173"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:se.gateway||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"DHCPv6\u670D\u52A1\u5668"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:se.dhcpServer||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u9996\u9009DNSv6"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:se.primaryDNS||"\u672A\u83B7\u53D6"})]}),(0,e.jsxs)(l.Z,{xs:24,sm:12,children:[(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",marginBottom:"4px"},children:"\u5907\u7528DNSv6"}),(0,e.jsx)("div",{style:{fontSize:"14px",fontWeight:500,fontFamily:"monospace"},children:se.secondaryDNS||"\u672A\u83B7\u53D6"})]})]})})})]})})}),(0,e.jsx)(l.Z,{xs:24,children:(0,e.jsx)(A.Z,{title:(0,e.jsxs)("div",{style:{display:"flex",alignItems:"center",gap:"8px"},children:[(0,e.jsx)("span",{children:"\u6A21\u7EC4\u6E29\u5EA6\u76D1\u63A7"}),(0,e.jsx)("div",{style:{fontSize:"12px",color:"#666",background:"#f5f5f5",padding:"2px 8px",borderRadius:"4px",fontWeight:"normal"},children:"5G\u6A21\u7EC4\u5404\u529F\u80FD\u6A21\u5757\u6E29\u5EA6\u72B6\u6001"})]}),extra:(0,e.jsxs)(fe.ZP,{type:"link",size:"small",style:{padding:"0 8px",height:"28px",display:"flex",alignItems:"center",gap:"4px",background:L.tempMonitor.enabled?"#e6f7ff":"transparent",border:"1px solid #91d5ff",borderRadius:"4px"},onClick:function(r){r.target.closest(".ant-input-number")||le("tempMonitor",!L.tempMonitor.enabled,L.tempMonitor.interval)},children:[(0,e.jsx)("span",{children:"\u81EA\u52A8\u5237\u65B0"}),L.tempMonitor.enabled&&(0,e.jsx)(be.Z,{min:1,max:60,value:L.tempMonitor.interval,onChange:function(r){return le("tempMonitor",!0,r||5)},style:{width:45},size:"small",bordered:!1}),L.tempMonitor.enabled&&(0,e.jsx)("span",{children:"\u79D2"})]}),className:"inner-card",bodyStyle:{padding:"24px"},children:(0,e.jsxs)(W.Z,{gutter:[16,16],children:[(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,lg:6,children:(0,e.jsx)(A.Z,{size:"small",bordered:!1,className:"temperature-card",style:{background:"#ffffff",boxShadow:"0 2px 8px rgba(0,0,0,0.08)",border:"1px solid #f0f0f0",transition:"all 0.3s ease"},hoverable:!0,children:(0,e.jsx)(_.Z,{title:(0,e.jsxs)("span",{children:["3G PA\u6E29\u5EA6"," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"(\u529F\u653E\u6E29\u5EA6)"})]}),value:B.sub3GPA,suffix:"\xB0C",valueStyle:{fontSize:"24px",fontWeight:500,color:B.sub3GPA<=45?"#52c41a":B.sub3GPA<=65?"#faad14":"#ff4d4f"}})})}),(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,lg:6,children:(0,e.jsx)(A.Z,{size:"small",bordered:!1,className:"temperature-card",style:{background:"#ffffff",boxShadow:"0 2px 8px rgba(0,0,0,0.08)",border:"1px solid #f0f0f0",transition:"all 0.3s ease"},hoverable:!0,children:(0,e.jsx)(_.Z,{title:(0,e.jsxs)("span",{children:["6G PA\u6E29\u5EA6"," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"(\u529F\u653E\u6E29\u5EA6)"})]}),value:B.sub6GPA,suffix:"\xB0C",valueStyle:{fontSize:"24px",fontWeight:500,color:B.sub6GPA<=45?"#52c41a":B.sub6GPA<=65?"#faad14":"#ff4d4f"}})})}),(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,lg:6,children:(0,e.jsx)(A.Z,{size:"small",bordered:!1,className:"temperature-card",style:{background:"#ffffff",boxShadow:"0 2px 8px rgba(0,0,0,0.08)",border:"1px solid #f0f0f0",transition:"all 0.3s ease"},hoverable:!0,children:(0,e.jsx)(_.Z,{title:(0,e.jsxs)("span",{children:["MIMO PA\u6E29\u5EA6"," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"(\u591A\u5165\u591A\u51FA\u529F\u653E)"})]}),value:B.mimoPa,suffix:"\xB0C",valueStyle:{fontSize:"24px",fontWeight:500,color:B.mimoPa<=45?"#52c41a":B.mimoPa<=65?"#faad14":"#ff4d4f"}})})}),(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,lg:6,children:(0,e.jsx)(A.Z,{size:"small",bordered:!1,className:"temperature-card",style:{background:"#ffffff",boxShadow:"0 2px 8px rgba(0,0,0,0.08)",border:"1px solid #f0f0f0",transition:"all 0.3s ease"},hoverable:!0,children:(0,e.jsx)(_.Z,{title:(0,e.jsxs)("span",{children:["TCXO\u6E29\u5EA6 ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"(\u6676\u632F\u6E29\u5EA6)"})]}),value:B.tcxo,suffix:"\xB0C",valueStyle:{fontSize:"24px",fontWeight:500,color:B.tcxo<=45?"#52c41a":B.tcxo<=65?"#faad14":"#ff4d4f"}})})}),(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,lg:6,children:(0,e.jsx)(A.Z,{size:"small",bordered:!1,className:"temperature-card",style:{background:"#ffffff",boxShadow:"0 2px 8px rgba(0,0,0,0.08)",border:"1px solid #f0f0f0",transition:"all 0.3s ease"},hoverable:!0,children:(0,e.jsx)(_.Z,{title:(0,e.jsxs)("span",{children:["AP1\u6E29\u5EA6"," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"(\u5E94\u7528\u5904\u7406\u56681)"})]}),value:B.ap1,suffix:"\xB0C",valueStyle:{fontSize:"24px",fontWeight:500,color:B.ap1<=45?"#52c41a":B.ap1<=65?"#faad14":"#ff4d4f"}})})}),(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,lg:6,children:(0,e.jsx)(A.Z,{size:"small",bordered:!1,className:"temperature-card",style:{background:"#ffffff",boxShadow:"0 2px 8px rgba(0,0,0,0.08)",border:"1px solid #f0f0f0",transition:"all 0.3s ease"},hoverable:!0,children:(0,e.jsx)(_.Z,{title:(0,e.jsxs)("span",{children:["AP2\u6E29\u5EA6"," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"(\u5E94\u7528\u5904\u7406\u56682)"})]}),value:B.ap2,suffix:"\xB0C",valueStyle:{fontSize:"24px",fontWeight:500,color:B.ap2<=45?"#52c41a":B.ap2<=65?"#faad14":"#ff4d4f"}})})}),(0,e.jsx)(l.Z,{xs:24,sm:12,md:8,lg:6,children:(0,e.jsx)(A.Z,{size:"small",bordered:!1,className:"temperature-card",style:{background:"#ffffff",boxShadow:"0 2px 8px rgba(0,0,0,0.08)",border:"1px solid #f0f0f0",transition:"all 0.3s ease"},hoverable:!0,children:(0,e.jsx)(_.Z,{title:(0,e.jsxs)("span",{children:["Modem1\u6E29\u5EA6"," ",(0,e.jsx)("span",{style:{fontSize:"12px",color:"#666"},children:"(\u8C03\u5236\u89E3\u8C03\u56681)"})]}),value:B.modem1,suffix:"\xB0C",valueStyle:{fontSize:"24px",fontWeight:500,color:B.modem1<=45?"#52c41a":B.modem1<=65?"#faad14":"#ff4d4f"}})})})]})})})]}),(0,e.jsx)("style",{dangerouslySetInnerHTML:{__html:`
        .network-info-card .ant-card-head-title {
          white-space: normal;
          overflow: visible;
        }
        
        .network-info-card .ant-card-extra {
          margin-left: 10px;
          white-space: normal;
        }
        
        @media (max-width: 576px) {
          .network-info-card .ant-card-extra {
            margin-left: 0;
            margin-top: 5px;
          }
          
          .inner-card .ant-card-head {
            min-height: unset;
            padding: 0 12px;
          }
          
          .inner-card .ant-card-head-title,
          .inner-card .ant-card-extra {
            padding: 8px 0;
            font-size: 14px;
          }
          
          .inner-card .ant-card-body {
            padding: 12px;
          }
          
          .ant-statistic-title {
            font-size: 12px;
          }
          
          .ant-statistic-content {
            font-size: 16px;
          }
        }
        
        .stats-card {
          background: var(--ant-card-bg);
          border-radius: 8px;
          transition: all 0.3s;
        }
        
        .stats-card:hover {
          box-shadow: 0 2px 8px var(--ant-shadow-1);
        }
        
        .stats-card .ant-card-head {
          min-height: 40px;
          padding: 0 16px;
          border-bottom: 1px solid var(--ant-border-color-split);
        }
        
        .stats-card .ant-card-head-title {
          padding: 12px 0;
          font-size: 16px;
          font-weight: 500;
        }
        
        .stats-card .ant-card-body {
          padding: 16px;
        }
        
        .stats-card .ant-statistic-title {
          margin-bottom: 8px;
          color: var(--ant-text-color-secondary);
        }
        
        .stats-card .ant-statistic-content {
          font-weight: 500;
          color: var(--ant-text-color);
        }
        
        @media (max-width: 576px) {
          .stats-card .ant-card-body {
            padding: 12px;
          }
          
          .stats-card .ant-statistic-content {
            font-size: 16px !important;
          }
        }
        
        .speed-info-card {
          background: var(--ant-card-bg);
          border-radius: 8px;
          transition: all 0.3s;
          height: 100%;
          border: 1px solid var(--ant-border-color-split);
        }
        
        .speed-info-card:hover {
          box-shadow: 0 4px 12px var(--ant-shadow-2);
          transform: translateY(-2px);
          border-color: var(--ant-primary-color);
        }
        
        .speed-info-card .ant-statistic-title {
          margin-bottom: 12px;
          color: var(--ant-text-color-secondary);
        }
        
        .speed-info-card .ant-statistic-content {
          line-height: 1.4;
          white-space: normal;
          word-break: break-all;
          color: var(--ant-text-color);
        }
        
        .speed-info-card .ant-statistic-content-suffix {
          color: var(--ant-text-color-secondary);
          font-size: 14px;
        }
        
        @media (max-width: 576px) {
          .speed-info-card {
            margin-bottom: 12px;
          }
          
          .speed-info-card .ant-statistic-content {
            font-size: 16px !important;
          }
        }
        
        .ant-input-number-handler-wrap {
          opacity: 0.5;
        }
        
        .ant-input-number:hover .ant-input-number-handler-wrap {
          opacity: 1;
        }
        
    
        
        .ant-input-number {
          background: transparent;
        }
        
        .ant-input-number-input {
          text-align: center;
          color: var(--ant-primary-color);
        }
        
        .ant-btn-text {
          color: var(--ant-text-color-secondary);
        }
        
        .ant-btn-text:hover {
          color: var(--ant-primary-color);
          background: transparent;
        }
        
        .ant-btn-link {
          color: var(--ant-primary-color);
        }
        
        .ant-btn-link:hover {
          color: var(--ant-primary-color-hover);
          background: var(--ant-primary-1);
          border-color: var(--ant-primary-color-hover);
        }
        
        .temperature-card {
          background: #ffffff;
          border-radius: 8px;
          transition: all 0.3s ease;
        }
        
        .temperature-card:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(0,0,0,0.12);
          border-color: #1890ff;
        }
        
        .temperature-card .ant-statistic-title {
          margin-bottom: 8px;
          color: #666;
        }
        
        .temperature-card .ant-statistic-content {
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        .temperature-card .ant-statistic-content-suffix {
          margin-left: 4px;
          font-size: 16px;
          color: #666;
        }
        
        @media (max-width: 576px) {
          .temperature-card {
            margin-bottom: 12px;
          }
          
          .temperature-card .ant-statistic-content {
            font-size: 20px !important;
          }
        }
        
        @media (max-width: 576px) {
          .ant-col-xs-12 {
            margin-bottom: 8px;
          }
          
          .ant-col-xs-12 .ant-statistic-content,
          .ant-col-xs-12 div[style*="fontSize: '22px'"] {
            font-size: 20px !important;
          }
          
          .ant-col-xs-12 div[style*="fontSize: '12px'"] {
            font-size: 11px !important;
            line-height: 1.2;
          }
        }
      `}}),(0,e.jsx)("style",{jsx:!0,global:!0,children:`
        @media screen and (max-width: 576px) {
          .signal-board-card {
            margin-bottom: 16px;
          }

          .signal-indicator {
            padding: 12px !important;
          }

          .signal-value {
            font-size: 20px !important;
          }

          .signal-unit {
            font-size: 12px !important;
          }

          .signal-title {
            font-size: 13px !important;
          }

          .signal-desc {
            font-size: 11px !important;
          }
        }
      `}),(0,e.jsx)("style",{jsx:!0,global:!0,children:`
        .network-dashboard {
          overflow: hidden;
          background: #fff;
          border-radius: 16px;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }

        .dashboard-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 16px 24px;
          color: white;
          background: linear-gradient(135deg, #1a237e, #0d47a1);
        }

        .network-status {
          display: flex;
          gap: 12px;
          align-items: center;
        }

        .status-badge {
          padding: 4px 12px;
          font-weight: 600;
          font-size: 14px;
          background: rgba(255, 255, 255, 0.2);
          border-radius: 20px;
        }

        .status-badge[data-mode='NR'] {
          background: #00c853;
        }

        .status-badge[data-mode='LTE'] {
          background: #2962ff;
        }

        .signal-overview {
          padding: 24px;
          background: linear-gradient(to bottom, #f5f5f5, #fff);
        }

        .signal-strength {
          display: flex;
          gap: 20px;
          align-items: center;
        }

        .signal-icon {
          color: #1a237e;
          font-size: 48px;
        }

        .signal-value {
          color: #1a237e;
          font-weight: 700;
          font-size: 36px;
        }

        .signal-metrics {
          display: flex;
          gap: 16px;
          color: #666;
          font-size: 14px;
        }

        .metrics-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
          gap: 16px;
          padding: 24px;
        }

        .metric-card {
          padding: 20px;
          background: #f8f9fa;
          border-radius: 12px;
          transition: all 0.3s ease;
        }

        .metric-card:hover {
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
          transform: translateY(-2px);
        }

        .metric-header {
          display: flex;
          gap: 8px;
          align-items: center;
          margin-bottom: 12px;
        }

        .metric-icon {
          font-size: 20px;
        }

        .metric-title {
          color: #1a237e;
          font-weight: 600;
        }

        .metric-value {
          margin-bottom: 8px;
          color: #1a237e;
          font-weight: 700;
          font-size: 28px;
        }

        .metric-unit {
          margin-left: 4px;
          color: #666;
          font-size: 14px;
        }

        .metric-desc {
          color: #666;
          font-size: 13px;
        }

        .carrier-info {
          padding: 24px;
          background: #f8f9fa;
        }

        .carrier-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          margin-bottom: 16px;
          color: #1a237e;
          font-weight: 600;
        }

        .carrier-count {
          padding: 4px 12px;
          font-size: 14px;
          background: #e3f2fd;
          border-radius: 20px;
        }

        .carrier-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
          gap: 16px;
        }

        .carrier-card {
          padding: 16px;
          background: white;
          border: 1px solid #e0e0e0;
          border-radius: 12px;
          transition: all 0.3s ease;
        }

        .carrier-card[data-primary='true'] {
          background: linear-gradient(135deg, #e8eaf6, #fff);
          border-color: #1a237e;
        }

        .carrier-title {
          display: flex;
          justify-content: space-between;
          margin-bottom: 12px;
          color: #1a237e;
          font-weight: 600;
        }

        .carrier-type {
          padding: 2px 8px;
          font-size: 12px;
          background: #e3f2fd;
          border-radius: 12px;
        }

        .carrier-details {
          display: grid;
          gap: 8px;
        }

        .detail-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          font-size: 14px;
        }

        .detail-item span {
          color: #666;
        }

        .detail-item strong {
          color: #1a237e;
        }

        @media (max-width: 576px) {
          .dashboard-header {
            padding: 12px 16px;
          }

          .signal-overview {
            padding: 16px;
          }

          .signal-icon {
            font-size: 36px;
          }

          .signal-value {
            font-size: 28px;
          }

          .metrics-grid {
            grid-template-columns: 1fr;
            padding: 16px;
          }

          .metric-card {
            padding: 16px;
          }

          .carrier-info {
            padding: 16px;
          }

          .carrier-grid {
            grid-template-columns: 1fr;
          }
        }
      `}),(0,e.jsx)("style",{jsx:!0,children:`
        .network-params {
          display: flex;
          flex-direction: column;
          gap: 12px;
        }

        .param-item {
          padding: 12px;
          background: var(--ant-card-bg);
          border: 1px solid var(--ant-border-color-split);
          border-radius: 8px;
          transition: all 0.3s ease;
        }

        .param-item:hover {
          border-color: var(--ant-primary-color);
          box-shadow: 0 2px 8px var(--ant-shadow-1);
          transform: translateY(-1px);
        }

        .param-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          margin-bottom: 8px;
        }

        .param-label {
          color: var(--ant-text-color-secondary);
          font-weight: 500;
          font-size: 13px;
        }

        .param-icon {
          width: 20px;
          height: 20px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: contain;
          opacity: 0.5;
        }

        .param-content {
          display: flex;
          gap: 8px;
          align-items: center;
          font-family: 'Roboto Mono', monospace;
        }

        .primary-value {
          color: var(--ant-primary-color);
          font-weight: 600;
          font-size: 15px;
        }

        .divider {
          color: var(--ant-border-color-split);
          font-size: 15px;
        }

        .secondary-value {
          color: var(--ant-text-color);
          font-weight: 600;
          font-size: 15px;
        }

        .signal-metrics-grid {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: 12px;
        }

        .signal-group {
          flex: 1;
          padding: 12px;
          background: var(--ant-card-bg);
          border: 1px solid var(--ant-border-color-split);
          border-radius: 8px;
          transition: all 0.3s ease;
        }

        .signal-group:hover {
          border-color: var(--ant-primary-color);
          box-shadow: 0 2px 8px var(--ant-shadow-1);
          transform: translateY(-2px);
        }

        .param-values {
          display: flex;
          gap: 8px;
          align-items: center;
          margin-bottom: 4px;
          color: var(--ant-text-color);
          font-weight: 600;
          font-size: 15px;
        }

        .param-desc {
          color: var(--ant-text-color-secondary);
          font-size: 12px;
        }

        @media (max-width: 576px) {
          .network-params {
            gap: 8px;
          }

          .param-item {
            padding: 10px;
          }

          .param-label {
            font-size: 12px;
          }

          .primary-value,
          .secondary-value,
          .divider {
            font-size: 13px;
          }

          .signal-metrics-grid {
            grid-template-columns: 1fr;
            gap: 8px;
          }

          .signal-group {
            padding: 10px;
          }

          .param-values {
            font-size: 14px;
          }

          .param-desc {
            font-size: 11px;
          }
        }
      `}),(0,e.jsx)("style",{jsx:!0,children:`
        .signal-metrics-grid {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: 12px;
        }

        .signal-group {
          flex: 1;
          padding: 12px;
          background: white;
          border: 1px solid #f0f0f0;
          border-radius: 8px;
          transition: all 0.3s ease;
        }

        .signal-group:hover {
          border-color: #1890ff;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
          transform: translateY(-2px);
        }

        .param-label {
          display: flex;
          gap: 6px;
          align-items: center;
          margin-bottom: 4px;
          color: #666;
          font-size: 13px;
        }

        .param-icon {
          font-size: 14px;
        }

        .param-values {
          display: flex;
          gap: 8px;
          align-items: center;
          margin-bottom: 4px;
          color: #1a237e;
          font-weight: 600;
          font-size: 15px;
        }

        .param-desc {
          color: #8c8c8c;
          font-size: 12px;
        }

        @media (max-width: 576px) {
          .signal-metrics-grid {
            grid-template-columns: 1fr;
            gap: 8px;
          }

          .signal-group {
            padding: 10px;
          }

          .param-values {
            font-size: 14px;
          }

          .param-desc {
            font-size: 11px;
          }
        }
      `}),(0,e.jsx)("style",{jsx:!0,children:`
        .signal-dashboard {
          padding: 4px 0;
        }

        .signal-strength-section {
          display: flex;
          gap: 16px;
          align-items: center;
        }

        .signal-metrics {
          display: flex;
          flex: 1;
          gap: 16px;
          align-items: center;
        }

        .signal-icon-wrapper {
          display: flex;
          flex-direction: column;
          gap: 4px;
          align-items: center;
          width: 60px;
          padding-right: 12px;
          border-right: 1px solid #f0f0f0;
        }

        .signal-percent {
          color: #262626;
          font-weight: 600;
          font-size: 14px;
        }

        .metrics-container {
          display: flex;
          flex: 1;
          gap: 12px;
          align-items: center;
          padding-left: 12px;
        }

        .metric-item {
          display: flex;
          flex: 1;
          flex-direction: column;
          gap: 2px;
          align-items: center;
          padding: 4px;
          text-align: center;
          border-radius: 4px;
          transition: all 0.3s ease;
        }

        .metric-item:hover {
          background: rgba(0, 0, 0, 0.02);
        }

        .metric-label {
          color: #8c8c8c;
          font-size: 12px;
        }

        .metric-value {
          font-weight: 600;
          font-size: 16px;
        }

        .metric-desc {
          max-width: 100px;
          color: #8c8c8c;
          font-size: 11px;
        }

        .carrier-list {
          display: flex;
          flex-direction: column;
          gap: 16px;
          max-width: 280px;
          margin-top: 16px;
          padding: 16px;
        }

        .carrier-item {
          display: flex;
          flex-direction: column;
          padding: 12px;
          background: #fff;
          border-radius: 8px;
          box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }

        .carrier-header {
          display: flex;
          gap: 8px;
          align-items: center;
          margin-bottom: 12px;
          padding-bottom: 8px;
          border-bottom: 1px solid #f0f0f0;
        }

        .band-name {
          color: #1f1f1f;
          font-weight: 600;
          font-size: 14px;
        }

        .band-desc {
          margin-left: 4px;
          color: #666;
          font-size: 12px;
        }

        .freq-info {
          display: flex;
          flex-direction: column;
          gap: 12px;
        }

        .freq-group {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .freq-title {
          margin-bottom: 4px;
          color: #666;
          font-size: 13px;
        }

        .freq-row {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 8px;
          align-items: center;
          padding: 6px 8px;
          background: #f9f9f9;
          border-radius: 4px;
        }

        .freq-value {
          color: #1f1f1f;
          font-size: 13px;
          font-family: 'SF Mono', SFMono-Regular, Consolas, monospace;
          text-align: center;
        }

        .freq-value:first-child {
          text-align: left;
        }

        .freq-value:last-child {
          text-align: right;
        }

        @media (max-width: 768px) {
          .carrier-list {
            max-width: none;
          }

          .carrier-item {
            padding: 12px;
          }
        }
      `}),(0,e.jsx)("style",{jsx:!0,children:`
        .carrier-info {
          margin-top: 16px;
        }

        .carrier-list {
          display: flex;
          flex-direction: column;
          gap: 8px;
          max-width: 280px;
        }

        .carrier-item {
          padding: 12px;
          background: var(--ant-card-bg);
          border-radius: 6px;
          box-shadow: 0 1px 2px var(--ant-shadow-1);
        }

        .carrier-header {
          display: flex;
          gap: 8px;
          align-items: center;
          margin-bottom: 8px;
        }

        .band-name {
          color: var(--ant-text-color);
          font-weight: 600;
          font-size: 12px;
        }

        .band-desc {
          color: var(--ant-text-color-secondary);
          font-size: 11px;
        }

        .freq-info {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .freq-row {
          display: flex;
          gap: 8px;
          align-items: center;
          padding: 4px 8px;
          background: var(--ant-bg-elevated);
          border-radius: 4px;
        }

        .freq-label {
          flex-shrink: 0;
          width: 32px;
          color: var(--ant-text-color-secondary);
          font-size: 11px;
        }

        .freq-value {
          color: var(--ant-text-color);
          font-size: 11px;
          font-family: 'SF Mono', SFMono-Regular, Consolas, monospace;
        }

        .temperature-card {
          background: #ffffff;
          border-radius: 8px;
          transition: all 0.3s ease;
        }

        .temperature-card:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(0,0,0,0.12);
          border-color: #1890ff;
        }

        .temperature-value {
          color: var(--ant-text-color);
          font-size: 24px;
          font-weight: 500;
        }

        .temperature-value.normal {
          color: var(--ant-success-color);
        }

        .temperature-value.warning {
          color: var(--ant-warning-color);
        }

        .temperature-value.danger {
          color: var(--ant-error-color);
        }

        .temperature-label {
          color: var(--ant-text-color-secondary);
          font-size: 12px;
        }

        @media (max-width: 768px) {
          .carrier-list {
            max-width: none;
          }

          .carrier-item {
            padding: 12px;
          }

          .temperature-card {
            margin-bottom: 12px;
          }
        }
      `})]})};We.default=Hn}}]);
