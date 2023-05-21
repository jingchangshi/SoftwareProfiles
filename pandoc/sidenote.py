#!/usr/bin/env python3

"""
Pandoc filter to convert footnotes to sidenotes for Tufte CSS.
"""

from pandocfilters import toJSONFilter, Span, attributes, RawInline

counter = 0

def sidenote(key, value, format, meta):
    global counter  # yeah yeah I know.
    if key == 'Note':
        counter += 1
        label = RawInline('html', '''
<label for="sn-{}" class="margin-toggle sidenote-number"></label>
<input type="checkbox" id="sn-{}" class="margin-toggle"/>'''.format(counter,
                                                                    counter))
        sidenote = [label]
        sidenote.extend(
            [Span(attributes({'class': 'sidenote'}), x['c']) for x in value])
        return sidenote

if __name__ == "__main__":
    toJSONFilter(sidenote)
