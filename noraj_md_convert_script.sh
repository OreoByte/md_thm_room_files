#!/bin/bash
while getopts m:o:t: args
do
	case "${args}"
	in
	m) markdown=${OPTARG};;
	o) output_file=${OPTARG};;
	t) template_file=${OPTARG};;
	esac
done
if [[ $markdown != '' ]] && [[ $output_file != ''  ]]; then
	pandoc $markdown \
	-o $output_file \
	--from markdown+yaml_metadata_block+raw_html \
	--template $template_file \
	--table-of-contents \
	--toc-depth 6 \
	--number-sections \
	--top-level-division=chapter \
	--highlight-style breezedark
elif [[ $markdown != '' ]]; then
	filename='output_'
	filename+=$markdown
	filename+='_REPORT.pdf'

	pandoc $markdown \
	-o $filename \
	--from markdown+yaml_metadata_block+raw_html \
	--template $template_file \
	--table-of-contents \
	--toc-depth 6 \
	--number-sections \
	--top-level-division=chapter \
	--highlight-style breezedark
else
	echo -e "\nScript automate the manual options on <noraj> OSCP-Exam-Report-Template-Markdown github page\n"
	echo "-m | The report.md markdown file. (Required)"
	echo "-o | Output fileanme of document as a .pdf document. (NOT Required)"
	echo -e "-t | Selected markdown template file. (Required)\n"
	echo -e "./noraj_md_convert_script.sh -m report.md -o final_report.pdf -t eisvogel.tex\n"
fi
