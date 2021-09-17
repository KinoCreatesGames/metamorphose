package ext;

import h2d.Text.Align;

inline function center(text:h2d.Text) {
	text.textAlign = Align.Center;
}

inline function left(text:h2d.Text) {
	text.textAlign = Align.Left;
}

inline function right(text:h2d.Text) {
	text.textAlign = Align.Right;
}

/**
 * Gets the alignment xMin value 
 * @param text 
 */
inline function alignCalcX(text:h2d.Text) {
	return text.getSize().xMin;
}
