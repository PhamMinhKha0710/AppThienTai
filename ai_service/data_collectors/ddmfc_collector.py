"""
DDMFC Data Collector - Ban Chỉ Huy Phòng Chống Thiên Tai

Reliability: 1.0 (100%) - Official Government Source
"""
import feedparser
import requests
from datetime import datetime
from typing import List, Dict, Optional
import time


class DDMFCCollector:
    """
    Collect disaster alerts from DDMFC RSS feeds
    
    Website: http://www.ddmfcvietnam.gov.vn/
    RSS Feed: Available (URL may vary)
    """
    
    BASE_URL = "http://www.ddmfcvietnam.gov.vn"
    RSS_FEEDS = [
        f"{BASE_URL}/rss",
        f"{BASE_URL}/rss.xml",
        f"{BASE_URL}/feed",
        f"{BASE_URL}/tin-tuc/rss",
    ]
    
    def __init__(self, delay_seconds: float = 1.0):
        """
        Initialize collector
        
        Args:
            delay_seconds: Delay between requests
        """
        self.delay_seconds = delay_seconds
    
    def fetch_alerts(self, max_alerts: int = 50) -> List[Dict]:
        """
        Fetch disaster alerts from DDMFC RSS feeds
        
        Args:
            max_alerts: Maximum number of alerts to fetch
            
        Returns:
            List of alert dicts with structure:
            {
                'id': str,
                'source': 'DDMFC',
                'source_reliability': 1.0,
                'title': str,
                'content': str,
                'severity': str,
                'alert_type': str,
                'province': str,
                'created_at': str,
                'link': str,
                'verified': True,
                'confidence': 1.0
            }
        """
        all_alerts = []
        
        for rss_url in self.RSS_FEEDS:
            try:
                print(f"[DDMFC] Trying RSS feed: {rss_url}")
                feed = feedparser.parse(rss_url)
                
                if feed.entries:
                    print(f"[DDMFC] Found {len(feed.entries)} entries in feed")
                    
                    for entry in feed.entries[:max_alerts]:
                        alert = self._parse_rss_entry(entry)
                        if alert:
                            all_alerts.append(alert)
                    
                    # If we got results from this feed, use it
                    if all_alerts:
                        break
                
                time.sleep(self.delay_seconds)
                
            except Exception as e:
                print(f"[DDMFC] Error fetching RSS feed {rss_url}: {e}")
                continue
        
        # If RSS feeds don't work, try web scraping
        if not all_alerts:
            print("[DDMFC] RSS feeds not available, trying web scraping...")
            all_alerts = self._fetch_from_website(max_alerts)
        
        print(f"[DDMFC] Fetched {len(all_alerts)} alerts")
        return all_alerts
    
    def _parse_rss_entry(self, entry) -> Optional[Dict]:
        """
        Parse RSS entry into structured alert dict
        """
        try:
            # Extract title and content
            title = entry.get('title', '')
            summary = entry.get('summary', '')
            content = summary or title
            
            # Extract link
            link = entry.get('link', '')
            
            # Extract published date
            published = entry.get('published', '')
            created_at = self._parse_rss_date(published)
            
            # Extract severity and type from content
            severity = self._extract_severity(title + " " + content)
            alert_type = self._extract_alert_type(title + " " + content)
            province = self._extract_province(title + " " + content)
            
            # Generate ID
            alert_id = f"DDMFC_{int(created_at.timestamp())}"
            
            return {
                'id': alert_id,
                'source': 'DDMFC',
                'source_reliability': 1.0,
                'title': title,
                'content': content,
                'severity': severity,
                'alert_type': alert_type,
                'province': province,
                'district': None,
                'lat': None,
                'lng': None,
                'created_at': created_at.isoformat(),
                'link': link,
                'verified': True,
                'confidence': 1.0,
                'metadata': {
                    'rss_entry_id': entry.get('id', ''),
                    'fetched_at': datetime.now().isoformat()
                }
            }
            
        except Exception as e:
            print(f"[DDMFC] Error parsing RSS entry: {e}")
            return None
    
    def _parse_rss_date(self, date_str: str) -> datetime:
        """Parse RSS date string to datetime"""
        if not date_str:
            return datetime.now()
        
        try:
            # feedparser provides parsed date
            from feedparser import _parse_date as parse_date
            parsed = parse_date(date_str)
            if parsed:
                return datetime(*parsed[:6])
        except:
            pass
        
        # Try manual parsing
        try:
            # Common formats: "Mon, 15 Jan 2024 10:00:00 +0700"
            return datetime.strptime(date_str.split('+')[0].strip(), "%a, %d %b %Y %H:%M:%S")
        except:
            pass
        
        return datetime.now()
    
    def _extract_severity(self, text: str) -> str:
        """Extract severity from text"""
        text_lower = text.lower()
        
        if any(kw in text_lower for kw in ['nghiêm trọng', 'cực kỳ', 'khẩn cấp', 'cấp độ 4']):
            return 'critical'
        elif any(kw in text_lower for kw in ['cao', 'nguy hiểm', 'cấp độ 3']):
            return 'high'
        elif any(kw in text_lower for kw in ['trung bình', 'cấp độ 2']):
            return 'medium'
        else:
            return 'medium'
    
    def _extract_alert_type(self, text: str) -> str:
        """Extract alert type from text"""
        text_lower = text.lower()
        
        if any(kw in text_lower for kw in ['sơ tán', 'evacuation']):
            return 'evacuation'
        elif any(kw in text_lower for kw in ['lũ', 'lụt', 'flood', 'ngập']):
            return 'disaster'
        elif any(kw in text_lower for kw in ['bão', 'storm']):
            return 'weather'
        elif any(kw in text_lower for kw in ['thiên tai', 'disaster']):
            return 'disaster'
        else:
            return 'general'
    
    def _extract_province(self, text: str) -> str:
        """Extract province from text"""
        # Same province list as NCHMF collector
        provinces = [
            'Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Hải Phòng', 'Cần Thơ',
            'An Giang', 'Bà Rịa - Vũng Tàu', 'Bạc Liêu', 'Bắc Giang', 'Bắc Kạn',
            'Bắc Ninh', 'Bến Tre', 'Bình Định', 'Bình Dương', 'Bình Phước',
            'Bình Thuận', 'Cà Mau', 'Cao Bằng', 'Đắk Lắk', 'Đắk Nông',
            'Điện Biên', 'Đồng Nai', 'Đồng Tháp', 'Gia Lai', 'Hà Giang',
            'Hà Nam', 'Hà Tĩnh', 'Hải Dương', 'Hậu Giang', 'Hòa Bình',
            'Hưng Yên', 'Khánh Hòa', 'Kiên Giang', 'Kon Tum', 'Lai Châu',
            'Lâm Đồng', 'Lạng Sơn', 'Lào Cai', 'Long An', 'Nam Định',
            'Nghệ An', 'Ninh Bình', 'Ninh Thuận', 'Phú Thọ', 'Phú Yên',
            'Quảng Bình', 'Quảng Nam', 'Quảng Ngãi', 'Quảng Ninh', 'Quảng Trị',
            'Sóc Trăng', 'Sơn La', 'Tây Ninh', 'Thái Bình', 'Thái Nguyên',
            'Thanh Hóa', 'Thừa Thiên Huế', 'Tiền Giang', 'Trà Vinh', 'Tuyên Quang',
            'Vĩnh Long', 'Vĩnh Phúc', 'Yên Bái'
        ]
        
        text_lower = text.lower()
        for province in provinces:
            if province.lower() in text_lower:
                return province
        
        return 'Toàn quốc'
    
    def _fetch_from_website(self, max_alerts: int) -> List[Dict]:
        """
        Fallback: Fetch from website if RSS not available
        """
        # This would require web scraping implementation
        # Similar to NCHMF collector
        print("[DDMFC] Web scraping not yet implemented")
        return []


if __name__ == "__main__":
    # Test collector
    collector = DDMFCCollector()
    alerts = collector.fetch_alerts(max_alerts=10)
    
    print(f"\nFetched {len(alerts)} alerts:")
    for alert in alerts[:3]:
        print(f"\n- {alert['severity'].upper()}: {alert['title']}")
        print(f"  Province: {alert['province']}")
        print(f"  Created: {alert['created_at']}")













