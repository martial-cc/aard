VERSION = 0.1.0
AARD_ROOT = $$HOME/.config/aard

EXECUTABLES = aard aard_report aard_status
MANPAGE = aard.1

PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

all: aard

aard:
	@for e in ${EXECUTABLES}; do \
		sed "s/VERSION/${VERSION}/g" < "$$e.sh" \
		| sed -e "s,MAKECONFROOT,\${AARD_ROOT}," > "$$e"; \
	done

clean:
	@printf 'cleaning\n'
	@rm -f ${EXECUTABLES}

conf:
	@mkdir -p ${AARD_ROOT}
	@sed -e "s,MAKECONFROOT,${AARD_ROOT}," < "aard.conf.example" > "${AARD_ROOT}/aard.conf"
	@sh ./aard_setup.sh "${AARD_ROOT}/aard.conf"

help:
	@printf 'Version: %s\n' "${VERSION}"
	@printf 'Install path: %s\n' "${DESTDIR}${PREFIX}/bin"
	@printf 'Manpage path: %s\n' "${DESTDIR}${MANPREFIX}/man1"
	@printf 'Executables:\n'
	@for e in ${EXECUTABLES}; do \
		printf '\t%s\n' "$$e"; \
	done
	@printf 'Manpage:\n\t%s\n' "${MANPAGE}"

install: all
	@mkdir -p "${DESTDIR}${PREFIX}/bin"
	@for e in ${EXECUTABLES}; do \
		cp -f "$$e" "${DESTDIR}${PREFIX}/bin" && \
		chmod 755 "${DESTDIR}${PREFIX}/bin/$$e"; \
	done
	@mkdir -p "${DESTDIR}${MANPREFIX}/man1"
	@sed -e "s/VERSION/${VERSION}/" < "${MANPAGE}" > "${DESTDIR}${MANPREFIX}/man1/${MANPAGE}"
	@chmod 644 "${DESTDIR}${MANPREFIX}/man1/$$m"

uninstall:
	@printf "Uninstalling executable files from ${DESTDIR}${PREFIX}/bin\n"
	@for e in ${EXECUTABLES}; do \
		rm -f "${DESTDIR}${PREFIX}/bin/$$e"; \
	done
	@printf "Uninstalling manpage from ${DESTDIR}${MANPREFIX}/man1\n"
	@rm -f "${DESTDIR}${MANPREFIX}/man1/${MANPAGE}"

.PHONY: all clean conf help install uninstall
