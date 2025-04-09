rtl_line_count:
	@find ./rtl/ -name "*.v" | xargs cat | wc -l