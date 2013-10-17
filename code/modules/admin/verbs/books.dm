/client/proc/view_books()
	set category="Admin"
	set name="Book Information"
	var/dat = "<html><head><title>Book Panel</title></head>"
	dat+="<body>"
	dat+="<table border=1 cellspacing=5><B><tr><th>ID</th><th>Title</th><th>Author</th><th>Category</th><th>Uploader</th></B>"
	for(var/datum/book_entry/b in book_db)
		/*
		var/title = b.title
		var/author = b.author
		var/category = b.category
		var/uploader = b.uploader
		var/id = b.id
		*/
		dat += "<tr><td>[b.id]</td><td>[b.title]</td><td>[b.author]</td><td>[b.category]</td><td>[b.uploader]</td></tr>"
	dat+="</table>"
	dat+="Total:[book_db.len]"
	dat+="</body></html>"
	usr << browse(dat,"window=book_panel;size=500x500")

/client/proc/delete_book(id as num)
	set category="Admin"
	set name="Delete Book"
	set desc="(Book ID,see \"Book Information\")Deletes a book"
	if(id<=book_db.len && id>0)
		var/todel=new/savefile("libbooks/books/[id]_book.sav")
		var/datum/book_entry/delentry=book_db[id]
		if(id<book_db.len)
			var/tomove=new/savefile("libbooks/books/[book_db.len]_book.sav")
			todel["title"]<<tomove["title"]
			todel["author"]<<tomove["author"]
			todel["cat"]<<tomove["cat"]
			todel["contents"]<<tomove["contents"]
			todel["uploader"]<<tomove["uploader"]
			var/datum/book_entry/moveentry=book_db[book_db.len]
			delentry.title=moveentry.title
			delentry.author=moveentry.author
			delentry.category=moveentry.category
			delentry.contents=moveentry.contents
			delentry.uploader=moveentry.uploader
			fdel("libbooks/books/[book_db.len]_book.sav")		//Looks like savefiles are not equal to filenames
			book_db-=moveentry
		else
			fdel("libbooks/books/[id]_book.sav")
			book_db-=delentry
		var/book_ids=new/savefile("libbooks/ids.sav")
		book_ids["id"]<<book_db.len
	else
		usr<<"<font color=red><b>ERROR</b>:Invalid ID.</font>"

/client/proc/read_book(id as num)
	set category="Admin"
	set name="Read Book"
	set desc="(Book ID,see \"Book Information\")View the contents of a book"
	if(id<=book_db.len && id>0)
		var/datum/book_entry/b=book_db[id]
		usr << browse("<TT><I>Penned by [b.author].</I></TT> <BR>" + "[b.contents]", "window=book")
	else
		usr<<"<font color=red><b>ERROR</b>:Invalid ID.</font>"