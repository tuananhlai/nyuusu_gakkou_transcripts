all:
	bash ./script/get_latest.sh
	bash ./script/convert_mp4.sh
	bash ./script/gen_srt.sh