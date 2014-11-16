//Attaches each element of a list to a single string seperated by 'seperator'.
/proc/dd_list2text(var/list/the_list, separator)
	var/total = the_list.len
	if(!total)
		return
	var/count = 2
	var/newText = "[the_list[1]]"
	while(count <= total)
		if(separator)
			newText += separator
		newText += "[the_list[count]]"
		count++
	return newText

/proc/dd_text2list(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	var/loops = 0
	while(1)
		if(loops >= 1000)
			break
		loops++

		findPosition = findtext(text, separator, searchPosition, 0)
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
	return

/*
 * Text sanitization
 */

/proc/sanitize_simple(var/t,var/list/repl_chars = list("\n"="#","\t"="#","я"="&#255;","<"="(","&lt;"=")"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	return t

/proc/sanitize_simple_uni(var/t,var/list/repl_chars = list("\n"="#","\t"="#","я"="&#255;","<"="(","&lt;"=")"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	return t

/proc/sanitize_uni(var/t,var/list/repl_chars = list("\n"="#","\t"="#","я"="&#255;","<"="(","&lt;"=")"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	return t

proc/sanitize_russian(var/msg, var/html = 0) //Специально для всего, где не нужно убирать переносы строк и прочее.
	var/rep
	if(html)
		rep = "&#x44F;"
	else
		rep = "&#255;"
	var/index = findtext(msg, "я")
	while(index)
		msg = copytext(msg, 1, index) + rep + copytext(msg, index + 1)
		index = findtext(msg, "я")
	return msg

 /*
 * Text modification
 */

/proc/capitalize_uni(var/t as text)
	var/s = 2
	if (copytext(t,1,2) == ";")
		s += 1
	if (copytext(t,1,2) == ":")
		s += 2
	return pointization(uppertext_uni(copytext(t, s - 1, s)) + copytext(t, s))

/proc/pointization(text as text)
	if (!text)
		return
	if (copytext(text,1,2) == "*") //Emotes allowed.
		return text
	if (copytext(text,-1) in list("!", "?", "."))
		return text
	text += "."
	return text


/proc/uppertext_uni(text as text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 223)
			t += ascii2text(a - 32)
		else if (a == 184)
			t += ascii2text(168)
		else t += ascii2text(a)
	return t

/proc/lowertext_uni(text as text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 191 && a < 224)
			t += ascii2text(a + 32)
		else if (a == 168)
			t += ascii2text(184)
		else t += ascii2text(a)
	return t

proc/intonation(text)
	if (copytext(text,-3) == "!!!")
		text = uppertext_uni(text)
	if (copytext(text,-1) == "!")
		text = "<b>[text]</b>"
	return text

/*
 * Misc
 */

/proc/stringsplit(txt, character)
	var/cur_text = txt
	var/last_found = 1
	var/found_char = findtext(cur_text,character)
	var/list/list = list()
	if(found_char)
		var/fs = copytext(cur_text,last_found,found_char)
		list += fs
		last_found = found_char+length(character)
		found_char = findtext(cur_text,character,last_found)
	while(found_char)
		var/found_string = copytext(cur_text,last_found,found_char)
		last_found = found_char+length(character)
		list += found_string
		found_char = findtext(cur_text,character,last_found)
	list += copytext(cur_text,last_found,length(cur_text)+1)
	return list

// For drunken speak, etc
proc/slurring_uni(phrase) // using cp1251!
	phrase = rhtml_decode(phrase)
	var/index = findtext(phrase, "я")
	while(index)
		phrase = copytext(phrase, 1, index) + "Я" + copytext(phrase, index+1)
		index = findtext(phrase, "я")
	var
		leng=lentext(phrase)
		counter=lentext(phrase)
		newphrase=""
		newletter=""

	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(prob(33))
			if(lowertext(newletter)=="е")	newletter="ё"
			if(lowertext(newletter)=="и")	newletter="й"
			if(lowertext(newletter)=="а")	newletter="ах"
			if(lowertext(newletter)=="ы")	newletter="i"
		switch(rand(1,15))
			if(1,3,5,8)	newletter="[lowertext_uni(newletter)]"
			if(2,4,6,15)	newletter="[uppertext_uni(newletter)]"
			if(7)	newletter+="'"
			if(9,10)	newletter="<b>[newletter]</b>"
			if(11,12)	newletter="<big>[newletter]</big>"
			if(13)	newletter="<small>[newletter]</small>"
		newphrase+="[newletter]"
		counter-=1
	return newphrase

proc/stutter_uni(phrase,stunned)
	phrase = rhtml_decode(phrase)

	var/list/split_phrase = dd_text2list(phrase," ") //Split it up into words.

	var/list/unstuttered_words = split_phrase.Copy()
	var/i = rand(1,3)
	if(stunned) i = split_phrase.len
	for(,i > 0,i--) //Pick a few words to stutter on.

		if (!unstuttered_words.len)
			break
		var/word = pick(unstuttered_words)
		unstuttered_words -= word //Remove from unstuttered words so we don't stutter it again.
		var/index = split_phrase.Find(word) //Find the word in the split phrase so we can replace it.

		//Search for dipthongs (two letters that make one sound.)
		var/first_sound = copytext(word,1,2)
		var/first_letter = copytext(word,1,2)
		if(lowertext_uni(first_sound) in list("ч","ш","щ","с"))
			first_letter = first_sound

		//Repeat the first letter to create a stutter.
		var/rnum = rand(1,3)
		switch(rnum)
			if(1)
				word = "[first_letter]-[word]"
			if(2)
				word = "[first_letter]-[first_letter]-[word]"
			if(3)
				word = "[first_letter]-[first_letter]-[first_letter]-[word]"

		split_phrase[index] = word

	return sanitize_uni(dd_list2text(split_phrase," "))