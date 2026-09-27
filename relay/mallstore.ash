/*
 * mallstore.ash — KoLmafia mall accessibility relay override
 *
 * Purpose:
 *   - Keep the native mall store page and controls visually unchanged.
 *   - Make each mall item radio-circle pointer target 3x its native width/height.
 *   - Preserve native keyboard/form behavior, including Enter-to-buy.
 *   - Scale KoLmafia's item right-click (IRCM) popup to 3x its native size.
 *
 * Install:
 *   Put this file at: <KoLmafia root>/relay/mallstore.ash
 *   Then reload a mall store in the relay browser.
 *
 * The underlying mallstore.php response is still authoritative.  This override
 * only injects presentation/input-assistance CSS+JS into full HTML responses.
 * AJAX purchase responses have no </head>, so they pass through unchanged.
 */

void main()
{
	buffer page = visit_url();

	string patch =
		"<style id=\"kolmall-access-style\">"
		+ ".kolmall-radio-cell{position:relative !important;}"
		+ "input[type=\"radio\"][name=\"whichitem\"]{position:relative;z-index:3;}"
		+ ".kolmall-radio-hit{position:absolute;display:block;margin:0;padding:0;"
		+ "background:transparent;border:0;cursor:pointer;z-index:2;}"
		+ ".kolmall-ircm-big{transform:scale(3) !important;z-index:2147483647 !important;}"
		+ "</style>"
		+ "<script id=\"kolmall-access-script\">"
		+ "(function(){"
		+ "'use strict';"
		+ "var SCALE=3;"
		+ "var lastContext={x:0,y:0};"

		// Add an invisible label centered on each native mall radio.  Because it
		// is a real <label for=...>, clicking the larger area still performs the
		// browser's native radio selection/focus behavior.
		+ "function enlargeRadios(){"
		+ "var rs=document.querySelectorAll('input[type=\\\"radio\\\"][name=\\\"whichitem\\\"]');"
		+ "for(var i=0;i<rs.length;i++){"
		+ "var r=rs[i];"
		+ "if(r.getAttribute('data-kolmall-hit')==='1')continue;"
		+ "var host=r.parentElement;if(!host)continue;"
		+ "host.classList.add('kolmall-radio-cell');"
		+ "if(!r.id)r.id='kolmall-radio-'+i+'-'+Math.random().toString(36).slice(2);"
		+ "var hit=document.createElement('label');"
		+ "hit.className='kolmall-radio-hit';"
		+ "hit.htmlFor=r.id;"
		+ "hit.setAttribute('aria-hidden','true');"
		+ "host.appendChild(hit);"
		+ "r.setAttribute('data-kolmall-hit','1');"
		+ "syncOne(r,hit);"
		+ "}"
		+ "}"

		+ "function syncOne(r,hit){"
		+ "if(!r||!hit)return;"
		+ "var w=r.offsetWidth*SCALE,h=r.offsetHeight*SCALE;"
		+ "if(!w||!h)return;"
		+ "hit.style.width=w+'px';hit.style.height=h+'px';"
		+ "hit.style.left=(r.offsetLeft+(r.offsetWidth-w)/2)+'px';"
		+ "hit.style.top=(r.offsetTop+(r.offsetHeight-h)/2)+'px';"
		+ "}"

		+ "function syncRadios(){"
		+ "var rs=document.querySelectorAll('input[type=\\\"radio\\\"][name=\\\"whichitem\\\"]');"
		+ "for(var i=0;i<rs.length;i++){"
		+ "var r=rs[i],host=r.parentElement;if(!host)continue;"
		+ "var hit=host.querySelector('label.kolmall-radio-hit[for=\\\"'+r.id+'\\\"]');"
		+ "if(hit)syncOne(r,hit);"
		+ "}"
		+ "}"

		// IRCM builds action rows with ids such as pircm_<itemid>.  Find the
		// positioned popup containing those rows and scale that native popup.
		+ "function markIrcm(){"
		+ "var markers=document.querySelectorAll('[id^=\\\"pircm_\\\"]');"
		+ "for(var i=0;i<markers.length;i++){"
		+ "var marker=markers[i],popup=null,el=marker.parentElement;"
		+ "while(el&&el!==document.body){"
		+ "var pos=window.getComputedStyle(el).position;"
		+ "if(pos==='absolute'||pos==='fixed'){popup=el;break;}"
		+ "el=el.parentElement;"
		+ "}"
		+ "if(!popup)popup=marker.parentElement;"
		+ "if(!popup)continue;"
		+ "popup.classList.add('kolmall-ircm-big');"
		+ "var hx=lastContext.x>window.innerWidth/2?'right':'left';"
		+ "var hy=lastContext.y>window.innerHeight/2?'bottom':'top';"
		+ "popup.style.transformOrigin=hx+' '+hy;"
		+ "}"
		+ "}"

		+ "function boot(){"
		+ "enlargeRadios();syncRadios();markIrcm();"
		+ "window.addEventListener('resize',syncRadios,false);"
		+ "document.addEventListener('contextmenu',function(e){"
		+ "lastContext={x:e.clientX,y:e.clientY};"
		+ "window.setTimeout(markIrcm,0);window.setTimeout(markIrcm,40);"
		+ "},true);"
		+ "if(window.MutationObserver){"
		+ "new MutationObserver(function(){enlargeRadios();markIrcm();})"
		+ ".observe(document.body,{childList:true,subtree:true});"
		+ "}"
		+ "}"

		+ "if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',boot);"
		+ "else boot();"
		+ "})();"
		+ "</script>";

	// Full mall pages contain </head>.  AJAX purchase fragments generally do
	// not, so replace_string naturally leaves those responses untouched.
	page.replace_string("</head>", patch + "</head>");
	write(page);
}
