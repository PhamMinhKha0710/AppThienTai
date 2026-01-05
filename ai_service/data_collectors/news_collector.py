"""
News Aggregator - Collect disaster news from verified Vietnamese news sources

Reliability: 0.85-0.90 (with cross-reference)
"""
import feedparser
import requests
from datetime import datetime
from typing import List, Dict, Optional
import time
import re


class NewsCollector:
    """
    Aggregate disaster news from verified Vietnamese news outlets
    
    Sources:
    - VTV (Vietnam Television): 0.90 reliability
    - VOV (Voice of Vietnam): 0.85 reliability
    - VNA (Vietnam News Agency): 0.90 reliability
    - VnExpress: 0.85 reliability
    - Tuoi Tre Online: 0.85 reliability
    """
    
    TRUSTED_SOURCES = {
        'VTV': {
            'rss_urls': [
                'https://vtv.vn/thien-tai.rss',
                'https://vtv.vn/thoi-su.rss',
                'https://vtv.vn/xa-hoi.rss',
            ],
            'reliability': 0.90
        },
        'VOV': {
            'rss_urls': [
                'https://vov.vn/rss/thoi-su.rss',
                'https://vov.vn/rss/xa-hoi.rss',
            ],
            'reliability': 0.85
        },
        'VNA': {
            'rss_urls': [
                'https://vietnamnews.vn/rss',
            ],
            'reliability': 0.90
        },
        'VnExpress': {
            'rss_urls': [
                'https://vnexpress.net/rss/thoi-su.rss',
                'https://vnexpress.net/rss/xa-hoi.rss',
            ],
            'reliability': 0.85
        },
        'TuoiTre': {
            'rss_urls': [
                'https://tuoitre.vn/rss/thoi-su.rss',
                'https://tuoitre.vn/rss/xa-hoi.rss',
            ],
            'reliability': 0.85
        }
    }
    
    # Keywords to identify disaster-related news
    DISASTER_KEYWORDS = [
        'lũ lụt', 'bão', 'thiên tai', 'sơ tán', 'cứu hộ',
        'mưa lớn', 'ngập lụt', 'sạt lở', 'động đất', 'hạn hán',
        'flood', 'storm', 'typhoon', 'disaster', 'evacuation',
        'cảnh báo', 'khẩn cấp', 'nguy hiểm'
    ]
    
    def __init__(self, delay_seconds: float = 1.0):
        """
        Initialize collector
        
        Args:
            delay_seconds: Delay between requests
        """
        self.delay_seconds = delay_seconds
    
    def fetch_disaster_news(self, hours_back: int = 24, max_news: int = 100) -> List[Dict]:
        """
        Fetch disaster-related news from all trusted sources
        
        Args:
            hours_back: Number of hours to look back
            max_news: Maximum number of news items to fetch
            
        Returns:
            List of news dicts with structure:
            {
                'id': str,
                'source': str,  # 'NEWS_VTV', 'NEWS_VOV', etc.
                'source_reliability': float,
                'title': str,
                'content': str,
                'severity': str,
                'alert_type': str,
                'province': str,
                'created_at': str,
                'link': str,
                'verified': False,  # Needs cross-reference
                'confidence': float  # 0.85-0.90
            }
        """
        all_news = []
        cutoff_time = datetime.now().timestamp() - (hours_back * 3600)
        
        for source_name, config in self.TRUSTED_SOURCES.items():
            for rss_url in config['rss_urls']:
                try:
                    print(f"[News] Fetching from {source_name}: {rss_url}")
                    feed = feedparser.parse(rss_url)
                    
                    if not feed.entries:
                        continue
                    
                    for entry in feed.entries:
                        # Check if news is disaster-related
                        if not self._is_disaster_related(entry):
                            continue
                        
                        # Check if within time window
                        published_time = self._get_entry_timestamp(entry)
                        if published_time < cutoff_time:
                            continue
                        
                        news_item = self._parse_news_entry(entry, source_name, config['reliability'])
                        if news_item:
                            all_news.append(news_item)
                        
                        if len(all_news) >= max_news:
                            break
                    
                    time.sleep(self.delay_seconds)
                    
                    if len(all_news) >= max_news:
                        break
                        
                except Exception as e:
                    print(f"[News] Error fetching from {source_name} ({rss_url}): {e}")
                    continue
            
            if len(all_news) >= max_news:
                break
        
        print(f"[News] Fetched {len(all_news)} disaster-related news items")
        return all_news
    
    def _is_disaster_related(self, entry) -> bool:
        """Check if news entry is disaster-related"""
        title = entry.get('title', '').lower()
        summary = entry.get('summary', '').lower()
        content = (title + " " + summary).lower()
        
        return any(keyword in content for keyword in self.DISASTER_KEYWORDS)
    
    def _get_entry_timestamp(self, entry) -> float:
        """Get timestamp from RSS entry"""
        try:
            if hasattr(entry, 'published_parsed') and entry.published_parsed:
                return datetime(*entry.published_parsed[:6]).timestamp()
        except:
            pass
        
        # Fallback to current time
        return datetime.now().timestamp()
    
    def _parse_news_entry(self, entry, source_name: str, reliability: float) -> Optional[Dict]:
        """Parse news entry into structured dict"""
        try:
            title = entry.get('title', '')
            summary = entry.get('summary', '')
            content = summary or title
            link = entry.get('link', '')
            
            # Extract published date
            published_time = self._get_entry_timestamp(entry)
            created_at = datetime.fromtimestamp(published_time)
            
            # Extract severity and type
            severity = self._extract_severity(title + " " + content)
            alert_type = self._extract_alert_type(title + " " + content)
            province = self._extract_province(title + " " + content)
            
            # Generate ID
            alert_id = f"NEWS_{source_name}_{int(published_time)}"
            
            return {
                'id': alert_id,
                'source': f'NEWS_{source_name}',
                'source_reliability': reliability,
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
                'verified': False,  # Needs cross-reference with official sources
                'confidence': reliability,  # Lower than official sources
                'metadata': {
                    'news_source': source_name,
                    'fetched_at': datetime.now().isoformat(),
                    'requires_validation': True
                }
            }
            
        except Exception as e:
            print(f"[News] Error parsing news entry: {e}")
            return None
    
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
        elif any(kw in text_lower for kw in ['bão', 'storm', 'typhoon']):
            return 'weather'
        elif any(kw in text_lower for kw in ['thiên tai', 'disaster']):
            return 'disaster'
        else:
            return 'general'
    
    def _extract_province(self, text: str) -> str:
        """Extract province from text"""
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


if __name__ == "__main__":
    # Test collector
    collector = NewsCollector()
    news = collector.fetch_disaster_news(hours_back=24, max_news=20)
    
    print(f"\nFetched {len(news)} news items:")
    for item in news[:3]:
        print(f"\n- [{item['source']}] {item['severity'].upper()}: {item['title'][:80]}")
        print(f"  Province: {item['province']}")
        print(f"  Confidence: {item['confidence']}")










