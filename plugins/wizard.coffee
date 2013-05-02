$.plugin
	depends: 'dialog'
	provides: 'wizard'
, ->
	$: wizard: (slides...) ->
		if slides.length is 1 and $.type(slides[0]) in ['array','bling']
			slides = slides[0]
		currentSlide = 0
		modal = $.dialog(slides[0]).select('parentNode')
		dialogs = []
		slideChanger = (delta) -> switch slides.length
			when 0 then $.identity
			else ->
				newSlide = (currentSlide + delta) % slides.length
				while newSlide < 0
					newSlide += slides.length
				return if newSlide is currentSlide
				$.log "slideChange: #{currentSlide} -> #{newSlide}"
				currentDialog = $ dialogs[currentSlide]
				newDialog = $ dialogs[newSlide]
				# adjust style.left to transition the old slide out of the way
				width = currentDialog.width()[0]
				newLeft = if delta < 0 then window.innerWidth - width else 0
				$.log "newLeft: #{$.px newLeft}"
				currentDialog.removeClass('wiz-active')
					.css(left: $.px newLeft)
					.fadeOut()
				newDialog.addClass('wiz-active').css(
					opacity: 0
					display: 'block'
				).centerOn(modal).fadeIn()
				currentSlide = newSlide
		modal.delegate '.wiz-next', 'click', slideChanger(+1)
		modal.delegate '.wiz-back', 'click', slideChanger(-1)

		for slide in slides.slice(1)
			d = $.synth('div.dialog div.title + div.content').css
				left: $.px window.innerWidth
			slide = $.extend $.dialog.getDefaultOptions(), slide
			d.find('.title').append $.dialog.getContent slide.titleType, slide.title
			d.find('.content').append $.dialog.getContent slide.contentType, slide.content
			d.appendTo(modal).fadeOut(0)
		dialogs = modal.find('.dialog')
		dialogs.take(1).show()
		modal


