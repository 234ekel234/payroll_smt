Grover.configure do |config|
  config.options = {
    format: 'A4',
    margin: { top: '5mm', bottom: '5mm', left: '5mm', right: '5mm' },
    prefer_css_page_size: true,
    emulate_media: 'screen'
  }
end