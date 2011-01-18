//  
//  Copyright (C) 2011 Robert Dyer
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 

using Cairo;
using Gdk;
using Gtk;

namespace Plank.Services.Drawing
{
	public struct RGBColor
	{
		public double R;
		public double G;
		public double B;
		public double A;
		
		public RGBColor (double R, double G, double B, double A)
		{
			this.R = R;
			this.G = G;
			this.B = B;
			this.A = A;
		}
		
		public RGBColor.from_gdk (Gdk.Color color)
		{
			R = color.red / (double) uint16.MAX;
			G = color.green / (double) uint16.MAX;
			B = color.blue / (double) uint16.MAX;
			A = 1.0;
		}
		
		public RGBColor set_hue (double hue)
			requires (hue >= 0 && hue <= 360)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			h = hue;
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor set_sat (double sat)
			requires (sat >= 0 && sat <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			s = sat;
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor set_val (double val)
			requires (val >= 0 && val <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			v = val;
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor set_alpha (double alpha)
			requires (alpha >= 0 && alpha <= 1)
		{
			A = alpha;
			return this;
		}
		
		public double get_hue ()
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			return h;
		}

		public double get_sat ()
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			return s;
		}

		public double get_val ()
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			return v;
		}
		
		public RGBColor add_hue (double val)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			h = (((h + val) % 360) + 360) % 360;
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor set_min_sat (double sat)
			requires (sat >= 0 && sat <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			s = Math.fmax (s, sat);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor set_min_value (double val)
			requires (val >= 0 && val <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			v = Math.fmax (v, val);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor set_max_sat (double sat)
			requires (sat >= 0 && sat <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			s = Math.fmin (s, sat);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}

		public RGBColor set_max_val (double val)
			requires (val >= 0 && val <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			v = Math.fmin (v, val);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor multiply_sat (double amount)
			requires (amount >= 0)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			s = Math.fmin (1, s * amount);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor brighten_val (double amount)
			requires (amount >= 0 && amount <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			v = Math.fmin (1, v + (1 - v) * amount);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor darken_val (double amount)
			requires (amount >= 0 && amount <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			v = Math.fmax (0, v - (1 - v) * amount);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		public RGBColor darken_by_sat (double amount)
			requires (amount >= 0 && amount <= 1)
		{
			double h, s, v;
			rgb_to_hsv (R, G, B, out h, out s, out v);
			v = Math.fmax (0, v - amount * s);
			hsv_to_rgb (h, s, v, out R, out G, out B);
			
			return this;
		}
		
		void rgb_to_hsv (double r, double g, double b, out double h, out double s, out double v)
			requires (r >= 0 && r <= 1)
			requires (g >= 0 && g <= 1)
			requires (b >= 0 && b <= 1)
		{
			double min = Math.fmin (r, Math.fmin (g, b));
			double max = Math.fmax (r, Math.fmax (g, b));
			
			v = max;
			if (v == 0) {
				h = 0;
				s = 0;
				return;
			}
			
			// normalize value to 1
			r /= v;
			g /= v;
			b /= v;
			
			min = Math.fmin (r, Math.fmin (g, b));
			max = Math.fmax (r, Math.fmax (g, b));
			
			double delta = max - min;
			s = delta;
			if (s == 0) {
				h = 0;
				return;
			}
			
			// normalize saturation to 1
			r = (r - min) / delta;
			g = (g - min) / delta;
			b = (b - min) / delta;
			
			if (max == r) {
				h = 0 + 60 * (g - b);
				if (h < 0)
					h += 360;
			} else if (max == g) {
				h = 120 + 60 * (b - r);
			} else {
				h = 240 + 60 * (r - g);
			}
		}
		
		void hsv_to_rgb (double h, double s, double v, out double r, out double g, out double b)
			requires (h >= 0 && h <= 360)
			requires (s >= 0 && s <= 1)
			requires (v >= 0 && v <= 1)
		{
			r = 0; 
			g = 0; 
			b = 0;

			if (s == 0) {
				r = v;
				g = v;
				b = v;
			} else {
				int secNum;
				double fracSec;
				double p, q, t;
				
				secNum = (int) Math.floor (h / 60);
				fracSec = h / 60 - secNum;

				p = v * (1 - s);
				q = v * (1 - s * fracSec);
				t = v * (1 - s * (1 - fracSec));
				
				switch (secNum) {
				case 0:
					r = v;
					g = t;
					b = p;
					break;
				case 1:
					r = q;
					g = v;
					b = p;
					break;
				case 2:
					r = p;
					g = v;
					b = t;
					break;
				case 3:
					r = p;
					g = q;
					b = v;
					break;
				case 4:
					r = t;
					g = p;
					b = v;
					break;
				case 5:
					r = v;
					g = p;
					b = q;
					break;
				}
			}
		}
	}
	
	public class Drawing : GLib.Object
	{
		const string MISSING_ICONS = "application-default-icon;;application-x-executable";
		
		public static Pixbuf load_icon (string names, int width, int height)
		{
			List<string> all_names = new List<string> ();
			
			foreach (string s in names.split (";;"))
				all_names.append (s);
			foreach (string s in MISSING_ICONS.split (";;"))
				all_names.append (s);
			
			Pixbuf pbuf = null;
			
			foreach (string name in all_names) {
				pbuf = load_pixbuf (name, (int) Math.fmax (width, height));
				if (pbuf != null)
					break;
				
				if (name != all_names.nth_data (all_names.length ()))
					Logging.Logger.info<Drawing> ("Could not find icon '%s'".printf (name));
			}
			
			if (pbuf != null) {
				if (width != -1 && height != -1 && (width != pbuf.width || height != pbuf.height))
					return ar_scale (pbuf, width, height);
				return pbuf;
			}
			
			return get_empty_pixbuf ();
		}
		
		static Pixbuf get_empty_pixbuf ()
		{
			Pixbuf pbuf = new Pixbuf (Colorspace.RGB, true, 8, 1, 1);
			pbuf.fill (0x00000000);
			return pbuf;
		}
		
		static Pixbuf? load_pixbuf (string icon, int size)
		{
#if VALA_0_12
			Pixbuf pbuf = null;
#else
			unowned Pixbuf pbuf = null;
#endif
			try {
				if (IconTheme.get_default ().has_icon (icon))
					pbuf = IconTheme.get_default ().load_icon (icon, size, 0);
				else if (icon.contains (".")) {
					string[] parts = icon.split (".");
					if (IconTheme.get_default ().has_icon (parts [0]))
						pbuf = IconTheme.get_default ().load_icon (parts [0], size, 0);
				}
			} catch { }
			
#if VALA_0_12
			return pbuf;
#else
			if (pbuf == null)
				return null;
			
			Pixbuf tmp = pbuf.copy ();
			pbuf.unref ();
			return tmp;
#endif
		}
		
		public static Pixbuf ar_scale (Pixbuf source, int width, int height)
		{
			var xScale = (double) width / (double) source.width;
			var yScale = (double) height / (double) source.height;
			var scale = Math.fmin (xScale, yScale);
			
			if (scale == 1)
				return source;
			
			Pixbuf tmp = source.scale_simple ((int) (source.width * scale),
				(int) (source.height * scale),
				InterpType.HYPER);
			
			return tmp;
		}
		
		public static RGBColor average_color (Pixbuf source)
		{
			double rTotal = 0;
			double gTotal = 0;
			double bTotal = 0;
			
			uchar* dataPtr = source.get_pixels ();
			double pixels = source.height * source.rowstride / source.n_channels;
			
			for (int i = 0; i < pixels; i++) {
				uchar r = dataPtr [0];
				uchar g = dataPtr [1];
				uchar b = dataPtr [2];
				
				uchar max = (uchar) Math.fmax (r, Math.fmax (g, b));
				uchar min = (uchar) Math.fmin (r, Math.fmin (g, b));
				double delta = max - min;
				
				double sat = delta == 0 ? 0 : delta / max;
				double score = 0.2 + 0.8 * sat;
				
				rTotal += r * score;
				gTotal += g * score;
				bTotal += b * score;
				
				dataPtr += source.n_channels;
			}
			
			return RGBColor (rTotal / uint8.MAX / pixels,
							 gTotal / uint8.MAX / pixels,
							 bTotal / uint8.MAX / pixels,
							 1).set_val (0.8).multiply_sat (1.15);
		}
	}
}
