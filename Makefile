#
# Linux specific
#
MAKEFLAGS	+= --no-builtin-variables --no-print-directory

MAJOR_VERSION	= 0
MINOR_VERSION	= 0

TOPDIR		= $(CURDIR)
LIBDIR		= lib

prefix		= /usr/local
libdir		= $(prefix)/$(LIBDIR)
incdir		= $(prefix)/include

CC		= $(CROSS_COMPILE)gcc
AR		= $(CROSS_COMPILE)ar
RANLIB		= $(CROSS_COMPILE)ranlib
INSTALL		= install
LN		= ln

LIB		= libtree.a
SHLIB		= libtree.so.$(MAJOR_VERSION).$(MINOR_VERSION)
soname		= libtree.so.$(MAJOR_VERSION)

ARFLAGS		= cr
LDFLAGS		= -Wl,--version-script=libtree.map
CFLAGS		= -g -Os
BASE_CFLAGS	= -std=c99 -Wall -Werror -Wno-unused-function -fpic
ALL_CFLAGS	= $(BASE_CFLAGS) $(CFLAGS) $(EXTRA_CFLAGS)

libtree_srcs	= bst.c rb.c avl.c splay.c
libtree_objs	= $(patsubst %.c,%.o,$(libtree_srcs))


all: $(LIB) $(SHLIB) libtree.pc

%.o: %.c
	$(CC) $(ALL_CFLAGS) -o $@ -c $<

$(LIB): $(libtree_objs)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

$(SHLIB): $(libtree_objs) libtree.map
	$(CC) -shared $(ALL_CFLAGS) -Wl,-h$(soname) $(LDFLAGS) -o $@ $(libtree_objs)
	$(LN) -sf $@ libtree.so
	$(LN) -sf $@ $(soname)

%.pc: %.pc.in
	sed -e 's|@prefix@|$(prefix)|' -e 's|@libdir@|$(libdir)|' \
		-e 's|@major@|$(MAJOR_VERSION)|' \
		-e 's|@minor@|$(MINOR_VERSION)|' $< >$@

.depend: $(libtree_srcs)
	$(CC) -MM $(ALL_CFLAGS) $^ >$@


.PHONY: TAGS cscope
.PHONY: clean distclean
.PHONY: install uninstall

clean:
	rm -f $(libtree_objs) $(LIB) $(SHLIB)
	rm -f $(soname) libtree.so
	rm -f libtree.pc .depend

distclean: clean
	rm -f  cscope.out TAGS

TAGS:
	@find . -name "*.[ch]" | xargs etags

cscope:
	@cscope -b

install: all
	$(INSTALL) -D -m 644 libtree.h $(DESTDIR)/$(incdir)/libtree.h
	$(INSTALL) -D -m 644 libtree.a $(DESTDIR)/$(libdir)/libtree.a
	$(INSTALL) -D -m 755 $(SHLIB) $(DESTDIR)/$(libdir)/$(SHLIB)
	$(LN) -s $(SHLIB) $(DESTDIR)/$(libdir)/libtree.so
	$(INSTALL) -D libtree.pc $(DESTDIR)/$(libdir)/pkgconfig/libtree.pc

uninstall:
	rm -f $(DESTDIR)/$(libdir)/$(LIB)
	rm -f $(DESTDIR)/$(libdir)/$(SHLIB)
	rm -f $(DESTDIR)/$(libdir)/libtree.so
	rm -f $(DESTDIR)/$(libdir)/pkgconfig/libtree.pc
	rm -f $(DESTDIR)/$(incdir)/libtree.h

-include .depend
