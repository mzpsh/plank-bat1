//  
//  Copyright (C) 2011-2012 Robert Dyer, Rico Tzschichholz
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

using Plank.Services;

namespace Plank.Drawing
{
	/**
	 * A themed renderer for dock windows.
	 */
	public class DockTheme : Theme
	{
		const double MIN_INDICATOR_SIZE = 0.0;
		const double MAX_INDICATOR_SIZE = 10.0;
		
		[Description(nick = "horizontal-padding", blurb = "The padding on the left/right dock edges, in tenths of a percent of IconSize.")]
		public double HorizPadding { get; set; }
		
		[Description(nick = "top-padding", blurb = "The padding on the top dock edge, in tenths of a percent of IconSize.")]
		public double TopPadding { get; set; }
		
		[Description(nick = "top-padding", blurb = "The padding on the bottom dock edge, in tenths of a percent of IconSize.")]
		public double BottomPadding { get; set; }
		
		[Description(nick = "item-padding", blurb = "The padding between items on the dock, in tenths of a percent of IconSize.")]
		public double ItemPadding { get; set; }
		
		[Description(nick = "indicator-size", blurb = "The size of item indicators, in tenths of a percent of IconSize.")]
		public double IndicatorSize { get; set; }
		
		[Description(nick = "urgent-bounce", blurb = "The height (in percent of IconSize) to bounce an icon when the application sets urgent.")]
		public double UrgentBounceHeight { get; set; }
		
		[Description(nick = "launch-bounce", blurb = "The height (in percent of IconSize) to bounce an icon when launching an application.")]
		public double LaunchBounceHeight { get; set; }
		
		[Description(nick = "fade-opacity", blurb = "The opacity value (0 to 1) to fade the dock to when hiding it.")]
		public double FadeOpacity { get; set; }
		
		[Description(nick = "click-time", blurb = "The amount of time (in ms) for click animations.")]
		public int ClickTime { get; set; }
		
		[Description(nick = "urgent-bounce-time", blurb = "The amount of time (in ms) to bounce an urgent icon.")]
		public int UrgentBounceTime { get; set; }
		
		[Description(nick = "launch-bounce-time", blurb = "The amount of time (in ms) to bounce an icon when launching an application.")]
		public int LaunchBounceTime { get; set; }
		
		[Description(nick = "active-time", blurb = "The amount of time (in ms) for active window indicator animations.")]
		public int ActiveTime { get; set; }
		
		[Description(nick = "slide-time", blurb = "The amount of time (in ms) to slide icons into/out of the dock.")]
		public int SlideTime { get; set; }
		
		[Description(nick = "fade-time", blurb = "The time (in ms) to fade the dock in/out on a hide (if FadeOpacity is < 1).")]
		public int FadeTime { get; set; }
		
		[Description(nick = "hide-time", blurb = "The time (in ms) to slide the dock in/out on a hide (if FadeOpacity is 1).")]
		public int HideTime { get; set; }
		
		[Description(nick = "glow-size", blurb = "The size of the urgent glow (shown when dock is hidden), in tenths of a percent of IconSize.")]
		public int GlowSize { get; set; }
		
		[Description(nick = "glow-time", blurb = "The total time (in ms) to show the hidden-dock urgent glow.")]
		public int GlowTime { get; set; }
		
		[Description(nick = "glow-pulse-time", blurb = "The time (in ms) of each pulse of the hidden-dock urgent glow.")]
		public int GlowPulseTime { get; set; }
		
		[Description(nick = "urgent-hue-shift", blurb = "The hue-shift (-180 to 180) of the urgent indicator color.")]
		public int UrgentHueShift { get; set; }
		
		/**
		 * {@inheritDoc}
		 */
		protected override void reset_properties ()
		{
			base.reset_properties ();
			TopRoundness = 4;
			BottomRoundness = 0;
			HorizPadding = 0.0;
			TopPadding = -11.0;
			BottomPadding = 2.5;
			ItemPadding = 2.0;
			IndicatorSize = 5.0;
			UrgentBounceHeight = 5.0 / 3.0;
			LaunchBounceHeight = 0.625;
			FadeOpacity = 1.0;
			ClickTime = 300;
			UrgentBounceTime = 600;
			LaunchBounceTime = 600;
			ActiveTime = 300;
			SlideTime = 300;
			FadeTime = 250;
			HideTime = 150;
			GlowSize = 30;
			GlowTime = 10000;
			GlowPulseTime = 2000;
			UrgentHueShift = 150;
		}
		
		/**
		 * Creates a surface for the dock background.
		 *
		 * @param width the width of the background
		 * @param height the height of the background
		 * @param position the position of the dock
		 * @param model existing surface to use as basis of new surface
		 * @return a new dock surface with the background drawn on it
		 */
		public DockSurface create_background (int width, int height, Gtk.PositionType position, DockSurface model)
		{
			Logger.verbose ("DockTheme.create_background (width = %i, height = %i)", width, height);
			
			var surface = new DockSurface.with_dock_surface (width, height, model);
			surface.clear ();
			
			if (position == Gtk.PositionType.BOTTOM) {
				draw_background (surface);
				return surface;
			}
			
			DockSurface temp;
			if (position == Gtk.PositionType.TOP)
				temp = new DockSurface.with_dock_surface (width, height, surface);
			else
				temp = new DockSurface.with_dock_surface (height, width, surface);
			
			draw_background (temp);
			
			var cr = surface.Context;
			
			var rotate = 0.0;
			var x_offset = 0.0, y_offset = 0.0;
			
			switch (position) {
			default:
			case Gtk.PositionType.BOTTOM:
				break;
			case Gtk.PositionType.TOP:
				rotate = Math.PI;
				x_offset = -width;
				y_offset = -height;
				break;
			case Gtk.PositionType.LEFT:
				rotate = Math.PI_2;
				y_offset = -width;
				break;
			case Gtk.PositionType.RIGHT:
				rotate = -Math.PI_2;
				x_offset = -height;
				break;
			}
			
			cr.save ();
			cr.rotate (rotate);
			cr.set_source_surface (temp.Internal, x_offset, y_offset);
			cr.paint ();
			cr.restore ();
			
			return surface;
		}
		
		/**
		 * Creates a surface for an indicator.
		 *
		 * @param size the size of the indicator
		 * @param color the color of the indicator
		 * @param model existing surface to use as basis of new surface
		 * @return a new dock surface with the indicator drawn on it
		 */
		public DockSurface create_indicator (int size, Color color, DockSurface model)
		{
			Logger.verbose ("DockTheme.create_indicator (size = %i)", size);
			
			var surface = new DockSurface.with_dock_surface (size, size, model);
			surface.clear ();
			
			if (size <= 0)
				return surface;
			
			var cr = surface.Context;
			
			var x = size / 2;
			var y = x;
			
			cr.move_to (x, y);
			cr.arc (x, y, size / 2, 0, Math.PI * 2);
			
			var rg = new Pattern.radial (x, y, 0, x, y, size / 2);
			rg.add_color_stop_rgba (0, 1, 1, 1, 1);
			rg.add_color_stop_rgba (0.1, color.R, color.G, color.B, 1);
			rg.add_color_stop_rgba (0.2, color.R, color.G, color.B, 0.6);
			rg.add_color_stop_rgba (0.25, color.R, color.G, color.B, 0.25);
			rg.add_color_stop_rgba (0.5, color.R, color.G, color.B, 0.15);
			rg.add_color_stop_rgba (1.0, color.R, color.G, color.B, 0.0);
			
			cr.set_source (rg);
			cr.fill ();
			
			return surface;
		}
		
		/**
		 * Creates a surface for an urgent glow.
		 *
		 * @param size the size of the urgent glow
		 * @param color the color of the urgent glow
		 * @param model existing surface to use as basis of new surface
		 * @return a new dock surface with the urgent glow drawn on it
		 */
		public DockSurface create_urgent_glow (int size, Color color, DockSurface model)
		{
			Logger.verbose ("DockTheme.create_urgent_glow (size = %i)", size);
			
			var surface = new DockSurface.with_dock_surface (size, size, model);
			surface.clear ();
			
			if (size <= 0)
				return surface;
			
			var cr = surface.Context;
			
			var x = size / 2.0;
			
			cr.move_to (x, x);
			cr.arc (x, x, size / 2, 0, Math.PI * 2);
			
			var rg = new Pattern.radial (x, x, 0, x, x, size / 2);
			rg.add_color_stop_rgba (0, 1, 1, 1, 1);
			rg.add_color_stop_rgba (0.33, color.R, color.G, color.B, 0.66);
			rg.add_color_stop_rgba (0.66, color.R, color.G, color.B, 0.33);
			rg.add_color_stop_rgba (1.0, color.R, color.G, color.B, 0.0);
			
			cr.set_source (rg);
			cr.fill ();
			
			return surface;
		}

		/**
		 * Draws an active glow for an item.
		 *
		 * @param surface the surface to draw onto
		 * @param clip_buffer a region to clip the glow to
		 * @param rect the rect for the glow
		 * @param color the color of the glow
		 * @param opacity the opacity of the glow
		 * @param pos the dock's position
		 */
		public void draw_active_glow (DockSurface surface, DockSurface clip_buffer, Gdk.Rectangle rect, Color color, double opacity, Gtk.PositionType pos)
		{
			if (opacity <= 0.0)
				return;
			
			var cr = surface.Context;
			
			var rotate = 0.0;
			var xoffset = 0.0, yoffset = 0.0;
			
			Pattern gradient = null;
			
			switch (pos) {
			default:
			case Gtk.PositionType.BOTTOM:
				xoffset = (surface.Width - clip_buffer.Width) / 2.0;
				yoffset = surface.Height - clip_buffer.Height;
				
				gradient = new Pattern.linear (0, rect.y, 0, rect.y + rect.height);
				break;
			case Gtk.PositionType.TOP:
				rotate = Math.PI;
				xoffset = (-surface.Width - clip_buffer.Width) / 2.0;
				yoffset = -clip_buffer.Height;
				
				gradient = new Pattern.linear (0, rect.y + rect.height, 0, rect.y);
				break;
			case Gtk.PositionType.LEFT:
				rotate = Math.PI_2;
				xoffset = (surface.Height - clip_buffer.Height) / 2.0;
				yoffset = -clip_buffer.Width;
				
				gradient = new Pattern.linear (rect.x + rect.width, 0, rect.x, 0);
				break;
			case Gtk.PositionType.RIGHT:
				rotate = -Math.PI_2;
				xoffset = (-surface.Height - clip_buffer.Height) / 2.0;
				yoffset = surface.Width - clip_buffer.Width;
				
				gradient = new Pattern.linear (rect.x, 0, rect.x + rect.width, 0);
				break;
			}
			
			cr.save ();
			cr.rotate (rotate);
			cr.translate (xoffset, yoffset);
			if (pos == Gtk.PositionType.BOTTOM || pos == Gtk.PositionType.TOP)
				draw_inner_rect (cr, clip_buffer.Width, clip_buffer.Height);
			else
				draw_inner_rect (cr, clip_buffer.Height, clip_buffer.Width);
			cr.restore ();
			
			cr.set_line_width (LineWidth);
			cr.clip ();

			gradient.add_color_stop_rgba (0, color.R, color.G, color.B, 0);
			gradient.add_color_stop_rgba (1, color.R, color.G, color.B, 0.6 * opacity);
			
			cr.rectangle (rect.x, rect.y, rect.width, rect.height);
			cr.set_source (gradient);
			cr.fill ();
			
			cr.reset_clip ();
		}
		
		/**
		 * Draws a badge for an item.
		 *
		 * @param surface the surface to draw the badge onto
		 * @param icon_size the icon-size of the dock
		 * @param color the color of the badge
		 * @param count the number for the badge to show
		 */
		public void draw_item_count (DockSurface surface, int icon_size, Color color, int64 count)
		{
			var cr = surface.Context;
			
			var badge_color_start = color.copy ().brighten_val (1.0);
			var badge_color_middle = color.copy ().set_sat (0.87);
			var badge_color_end = color.copy ().set_sat (0.87).darken_val (0.7);
			var stroke_color_start = color.copy ().set_sat (0.9);
			var stroke_color_end = color.copy ().set_sat (0.9).darken_val (0.9);
			
			// FIXME enhance scalability and adjustments depending on icon-size
			var is_small = icon_size < 32;
			var is_large = icon_size > 54;
			var padding = (is_small ? 1.0 : (is_large ? 4.5 : 2.0));
			var line_width = (is_small ? 0.0 : (is_large ? 2.0 : 1.0));

			var height = Math.floor ((is_small ? 0.80 : 0.50) * double.min (surface.Width, surface.Height) - 2.0 * line_width);
			var width = Math.floor ((0.75 + 0.25 * count.to_string ().length) * height);
			var max_width = surface.Width - 2.0 * line_width;
			if (width > max_width)
				width = max_width;
			var x = surface.Width - width - line_width / 2.0;
			var y = line_width + line_width / 2.0;
			
			cr.set_line_width (line_width);
			
			Pattern stroke, fill;
			
			if (!is_small) {
				// draw outline shadow
				stroke = new Pattern.rgba (0.2, 0.2, 0.2, 0.3);
				draw_rounded_line (cr, x, y, width + line_width, height, true, true, stroke, null);
				
				// draw filled gradient with outline
				stroke = new Pattern.linear (0, y, 0, y + height);
				stroke.add_color_stop_rgba (0.2, stroke_color_start.R, stroke_color_start.G, stroke_color_start.B, 0.8);
				stroke.add_color_stop_rgba (0.8, stroke_color_end.R, stroke_color_end.G, stroke_color_end.B, 0.8);
				fill = new Pattern.linear (0, y, 0, y + height);
				fill.add_color_stop_rgba (0.1, badge_color_start.R, badge_color_start.G, badge_color_start.B, 1.0);
				fill.add_color_stop_rgba (0.5, badge_color_middle.R, badge_color_middle.G, badge_color_middle.B, 1.0);
				fill.add_color_stop_rgba (0.9, badge_color_end.R, badge_color_end.G, badge_color_end.B, 1.0);
				draw_rounded_line (cr, x, y, width, height, true, true, stroke, fill);
				
				// draw inline highlight
				stroke = new Pattern.rgba (0.9, 0.9, 0.9, 0.1);
				draw_rounded_line (cr, x + line_width, y + line_width, width - 2 * line_width, height - 2 * line_width, true, true, stroke, null);
			}
			
			var layout = new Pango.Layout (pango_context_get ());
			layout.set_width ((int) (width * Pango.SCALE));
			layout.set_ellipsize (Pango.EllipsizeMode.NONE);
			
			var font_description = new Gtk.Style ().font_desc;
			font_description.set_absolute_size ((int) (height * Pango.SCALE));
			font_description.set_weight (Pango.Weight.BOLD);
			layout.set_font_description (font_description);
			
			layout.set_text (count.to_string (), -1);
			Pango.Rectangle ink_rect, logical_rect;
			layout.get_pixel_extents (out ink_rect, out logical_rect);
			
			var scale = double.min (1.0, double.min ((width - 2.0 * padding - 2.0 * line_width) / (double) logical_rect.width, (height - 2.0 * padding) / (double) logical_rect.height));
			
			if (!is_small)
				cr.set_source_rgba (0.0, 0.0, 0.0, 0.2);
			else
				cr.set_source_rgba (0.0, 0.0, 0.0, 0.6);
			
			cr.move_to (x + Math.floor (width / 2.0 - scale * logical_rect.width / 2.0), y + Math.floor (height / 2.0 - scale * logical_rect.height / 2.0));
			
			// draw text
			cr.save ();
			if (scale < 1)
				cr.scale (scale, scale);
			
			cr.set_line_width (line_width);
			Pango.cairo_layout_path (cr, layout);
			cr.stroke_preserve ();
			cr.set_source_rgba (1.0, 1.0, 1.0, 0.95);
			cr.fill ();
			cr.restore ();
		}


		/**
		 * Draws a progress bar for an item.
		 *
		 * @param surface the surface to draw the progress onto
		 * @param icon_size the icon-size of the dock
		 * @param color the color of the progress
		 * @param progress the value between 0.0 and 1.0
		 */
		public void draw_item_progress (DockSurface surface, int icon_size, Color color, double progress)
		{
			if (progress < 0)
				return;
			
			var cr = surface.Context;
			
			// FIXME enhance scalability and adjustments depending on icon-size
			var line_width = 1.0;
			var padding = 4.0;
			var width = surface.Width - 2.0 * padding;
			var height = Math.floor (double.min (18.0, (int) (0.15 * surface.Height)));
			var x = padding;
			var y = surface.Height - height - padding;
			
			cr.set_line_width (line_width);
			
			Pattern stroke, fill;
			
			// draw the outer stroke
			stroke = new Pattern.linear (0, y, 0, y + height);
			stroke.add_color_stop_rgba (0.5, 0.5, 0.5, 0.5, 0.1);
			stroke.add_color_stop_rgba (0.9, 0.8, 0.8, 0.8, 0.4);
			draw_rounded_line (cr, x + line_width / 2.0, y + line_width / 2.0, width, height, true, true, stroke, null);
			
			// draw the background
			x += line_width;
			y += line_width;
			width -= 2.0 * line_width;
			height -= 2.0 * line_width;
			
			stroke = new Pattern.rgba (0.20, 0.20, 0.20, 0.9);
			fill = new Pattern.linear (0, y, 0, y + height);
			fill.add_color_stop_rgba (0.4, 0.25, 0.25, 0.25, 1.0);
			fill.add_color_stop_rgba (0.9, 0.35, 0.35, 0.35, 1.0);
			draw_rounded_line (cr, x + line_width / 2.0, y + line_width / 2.0, width, height, true, true, stroke, fill);
			
			// draw the finished bar
			x += line_width;
			y += line_width;
			width -= 2.0 * line_width;
			height -= 2.0 * line_width;
			
			var finished_width = Math.ceil (progress * width);
			stroke = new Pattern.rgba (0.8, 0.8, 0.8, 1.0);
			fill = new Pattern.rgba (0.9, 0.9, 0.9, 1.0);
			draw_rounded_line (cr, x + line_width / 2.0, y + line_width / 2.0, finished_width, height, true, true, stroke, fill);
		}
		
		/**
		 * {@inheritDoc}
		 */
		protected override void verify (string prop)
		{
			base.verify (prop);
			
			switch (prop) {
			case "HorizPadding":
				break;
			
			case "TopPadding":
				break;
			
			case "BottomPadding":
				if (BottomPadding < 0)
					BottomPadding = 0;
				break;
			
			case "ItemPadding":
				if (ItemPadding < 0)
					ItemPadding = 0;
				break;
			
			case "IndicatorSize":
				if (IndicatorSize < MIN_INDICATOR_SIZE)
					IndicatorSize = MIN_INDICATOR_SIZE;
				else if (IndicatorSize > MAX_INDICATOR_SIZE)
					IndicatorSize = MAX_INDICATOR_SIZE;
				break;
			
			case "UrgentBounceHeight":
				if (UrgentBounceHeight < 0)
					UrgentBounceHeight = 0;
				break;
			
			case "LaunchBounceHeight":
				if (LaunchBounceHeight < 0)
					LaunchBounceHeight = 0;
				break;
			
			case "FadeOpacity":
				if (FadeOpacity < 0)
					FadeOpacity = 0;
				else if (FadeOpacity > 1)
					FadeOpacity = 1;
				break;
			
			case "ClickTime":
				if (ClickTime < 0)
					ClickTime = 0;
				break;
			
			case "UrgentBounceTime":
				if (UrgentBounceTime < 0)
					UrgentBounceTime = 0;
				break;
			
			case "LaunchBounceTime":
				if (LaunchBounceTime < 0)
					LaunchBounceTime = 0;
				break;
			
			case "ActiveTime":
				if (ActiveTime < 0)
					ActiveTime = 0;
				break;
			
			case "SlideTime":
				if (SlideTime < 0)
					SlideTime = 0;
				break;
			
			case "FadeTime":
				if (FadeTime < 0)
					FadeTime = 0;
				break;
			
			case "HideTime":
				if (HideTime < 0)
					HideTime = 0;
				break;
			
			case "GlowSize":
				if (GlowSize < 0)
					GlowSize = 0;
				break;
			
			case "GlowTime":
				if (GlowTime < 0)
					GlowTime = 0;
				break;
			
			case "GlowPulseTime":
				if (GlowPulseTime < 0)
					GlowPulseTime = 0;
				break;
			
			case "UrgentHueShift":
				if (UrgentHueShift < -180)
					UrgentHueShift = -180;
				else if (UrgentHueShift > 180)
					UrgentHueShift = 180;
				break;
			}
		}
	}
}